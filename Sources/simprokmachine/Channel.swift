//
//  File 2.swift
//  
//
//  Created by Andriy Prokhorenko on 02.07.2023.
//


final class ChannelIterator<T>: Sendable, AsyncIteratorProtocol {
    typealias Element = T
    
    private final class Id {
        
        private init() {}
        
        static func generate() -> String {
            "\(ObjectIdentifier(Id()))"
        }
    }
    
    private let state = ManagedCriticalState(ChannelState<T>.idle)

    
    func next() async -> T? {
        let id = Id.generate()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { cont in
                if Task.isCancelled {
                    cont.resume(returning: nil)
                    return
                }
                state.withCriticalRegion { state in
                    switch state {
                    case .idle:
                        state = .awaitingForProducer(cur: ChannelConsumer(id: id, cont: cont), rest: [])
                    case .awaitingForConsumer(let cur, let rest):
                        if rest.isEmpty {
                            state = .idle
                            cur.cont.resume()
                            cont.resume(returning: cur.value)
                        } else {
                            state = .awaitingForConsumer(cur: rest[0], rest: Array(rest.dropFirst()))
                            cur.cont.resume()
                            cont.resume(returning: cur.value)
                        }
                    case .awaitingForProducer(let cur, let rest):
                        state = .awaitingForProducer(cur: cur, rest: rest + [ChannelConsumer(id: id, cont: cont)])
                    }
                }
            }
        } onCancel: {
            state.withCriticalRegion { state in
                switch state {
                case .idle, .awaitingForConsumer:
                    break // do nothing, as there is no continuation to be resumed
                case .awaitingForProducer(let cur, let rest):
                    if cur.id == id {
                        if rest.isEmpty {
                            state = .idle
                            cur.cont.resume(returning: nil)
                        } else {
                            state = .awaitingForProducer(cur: rest[0], rest: Array(rest.dropFirst()))
                            cur.cont.resume(returning: nil)
                        }
                    } else {
                        let new = rest.filter { item in
                            if item.id == id {
                                item.cont.resume(returning: nil)
                                return true
                            } else {
                                return false
                            }
                        }
                        state = .awaitingForProducer(cur: cur, rest: new)
                    }
                }
            }
        }
    }
    
    func yield(_ val: T) async {
        let id = Id.generate()
        let _: Void = await withTaskCancellationHandler {
            await withCheckedContinuation { cont in
                if Task.isCancelled {
                    cont.resume()
                    return
                }
                state.withCriticalRegion { state in
                    switch state {
                    case .idle:
                        state = .awaitingForConsumer(cur: ChannelProducer(id: id, value: val, cont: cont), rest: [])
                    case .awaitingForProducer(let cur, let rest):
                        state = .idle
                        cur.cont.resume(returning: val)
                        rest.forEach { $0.cont.resume(returning: val) }
                        cont.resume()
                    case .awaitingForConsumer(let cur, let rest):
                        state = .awaitingForConsumer(cur: cur, rest: rest + [ChannelProducer(id: id, value: val, cont: cont)])
                    }
                }
            }
        } onCancel: {
            state.withCriticalRegion { state in
                switch state {
                case .idle, .awaitingForProducer:
                    break // do nothing, as there is no continuation to be resumed
                case .awaitingForConsumer(let cur, let rest):
                    if cur.id == id {
                        if rest.isEmpty {
                            state = .idle
                            cur.cont.resume()
                        } else {
                            state = .awaitingForConsumer(cur: rest[0], rest: Array(rest.dropFirst()))
                            cur.cont.resume()
                        }
                    } else {
                        let new = rest.filter { item in
                            if item.id == id {
                                item.cont.resume()
                                return true
                            } else {
                                return false
                            }
                        }
                        state = .awaitingForConsumer(cur: cur, rest: new)
                    }
                }
            }
        }
    }
}

final class Channel<T>: Sendable, AsyncSequence {
    typealias AsyncIterator = ChannelIterator<T>
    typealias Element = T
    
    private let iterator = ChannelIterator<T>()
    
    func makeAsyncIterator() -> ChannelIterator<T> { iterator }
    
    @Sendable
    func yield(_ val: T) async {
        await iterator.yield(val)
    }
}


enum ChannelState<T> {
    case idle
    case awaitingForProducer(cur: ChannelConsumer<T>, rest: [ChannelConsumer<T>])
    case awaitingForConsumer(cur: ChannelProducer<T>, rest: [ChannelProducer<T>])
}

struct ChannelProducer<T> {
    let id: String
    let value: T
    let cont: CheckedContinuation<Void, Never>
}

struct ChannelConsumer<T> {
    let id: String
    let cont: CheckedContinuation<T?, Never>
}
