//
//  CustomStream.swift
//  TestingAllTheStuff
//
//  Created by Andriy Prokhorenko on 23.06.2023.
//


internal final class CustomStream<T: Sendable>: AsyncSequence, Sendable {
    internal typealias Element = T

    private let iterator: CustomIterator<T>

    internal init(_ reducer: @escaping @Sendable ([T], T) -> [T]) {
        iterator = CustomIterator(reducer)
    }

    internal func makeAsyncIterator() -> CustomIterator<T> {
        iterator
    }
}

internal actor CustomIterator<T: Sendable>: AsyncIteratorProtocol, Sendable {
    
    private final class Id {}
    
    private let buffer: @Sendable ([T], T) -> [T]

    fileprivate init(_ reducer: @escaping @Sendable ([T], T) -> [T]) {
        self.buffer = reducer
    }

    private var state: IteratorState<T> = .empty

    internal func next() async -> T? {
        if Task.isCancelled {
            return nil
        }

        let id = ObjectIdentifier(Id())

        switch state {
        case .empty, .waiting:
            return await withTaskCancellationHandler {
                await withCheckedContinuation { cont in
                    if Task.isCancelled {
                        cont.resume(returning: nil)
                        return
                    }

                    // these double checks are necessary because of actor's reentrancy. by the time this piece
                    // of code is entered, there is a chance that "state" has been modified
                    switch state {
                    case .empty:
                        state = .waiting([id: cont])
                    case .waiting(let conts):
                        var copy = conts
                        copy[id] = cont
                        state = .waiting(copy)
                    case .buffered(let cur, let arr):
                        state = arr.isEmpty ? .empty : .buffered(arr[0], Array(arr.dropFirst(1)))
                        cont.resume(returning: cur)
                    }
                }
            } onCancel: {
                Task(priority: nil) {
                    await { (obj: isolated CustomIterator<T>) in
                        switch obj.state {
                        case .empty, .buffered:
                            break
                        case .waiting(let conts):
                            if let cont = conts[id] {
                                if conts.values.count == 1 {
                                    obj.state = .empty
                                } else {
                                    var copy = conts
                                    copy[id] = nil
                                    obj.state = .waiting(copy)
                                }
                                cont.resume(returning: nil)
                            }
                        }
                    }(self)
                }
            }
        case .buffered(let cur, let arr):
            state = arr.isEmpty ? .empty : .buffered(arr[0], Array(arr.dropFirst(1)))
            return cur
        }
    }

    internal nonisolated func send(_ val: T) {
        Task(priority: nil) {
            await { (obj: isolated CustomIterator<T>) in
                switch obj.state {
                case .empty:
                    obj.handleBuffering(current: buffer([], val))
                case .buffered(let cur, let arr):
                    obj.handleBuffering(current: buffer([cur] + arr, val))
                case .waiting(let conts):
                    conts.values.forEach { $0.resume(returning: val) }
                    obj.state = .empty
                }
            }(self)
        }
    }


    private func handleBuffering(current: [T]) {
        if current.isEmpty {
            state = .empty
        } else {
            let first = current[0]
            let rest = Array(current.dropFirst(1))
            state = .buffered(first, rest)
        }
    }
}


fileprivate enum IteratorState<T> {
    case empty
    case waiting([ObjectIdentifier: CheckedContinuation<T?, Never>])
    case buffered(T, [T])
}
