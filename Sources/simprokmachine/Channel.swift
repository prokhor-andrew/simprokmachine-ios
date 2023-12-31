//
//  File 2.swift
//  
//
//  Created by Andriy Prokhorenko on 02.07.2023.
//

final class ChannelIterator<T: Sendable, Loggable: Sendable>: Sendable, AsyncIteratorProtocol {
    typealias Element = T
    
    private let state = ManagedCriticalState(ChannelState<T>.idle)
    
    private let machineId: String
    private let logger: MachineLogger<Loggable>
    private let bufferStrategy: MachineBufferStrategy<T, Loggable>
    
    init(bufferStrategy: MachineBufferStrategy<T, Loggable>, logger: MachineLogger<Loggable>, machineId: String) {
        self.logger = logger
        self.bufferStrategy = bufferStrategy
        self.machineId = machineId
    }

    deinit {
        state.withCriticalRegion { state in
            switch state {
            case .awaitingForConsumer(let array):
                array.forEach { $0.cont.resume(returning: false) }
                state = .idle
            case .awaitingForProducer(let cur, let rest):
                cur.cont.resume(returning: nil)
                rest.forEach { $0.cont.resume(returning: nil) }
                state = .idle
            case .idle:
                break
            }
        }
    }
    
    func next() async -> T? {
        let id = String.id
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
                    case .awaitingForProducer(let cur, let rest):
                        state = .awaitingForProducer(cur: cur, rest: rest + [ChannelConsumer(id: id, cont: cont)])
                    case .awaitingForConsumer(let array):
                        array[0].cont.resume(returning: true) // array must never be empty so these lines are perfectly fine
                        cont.resume(returning: array[0].data)
                        
                        handleBuffer(&state, event: .removed(isConsumed: true), currentArray: Array(array.dropFirst()))
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
                            if item.id != id {
                                return true
                            } else {
                                item.cont.resume(returning: nil)
                                return false
                            }
                        }
                        state = .awaitingForProducer(cur: cur, rest: new)
                    }
                }
            }
        }
    }
    
    func yield(_ val: T) async -> Bool {
        let id = String.id
        return await withTaskCancellationHandler {
            await withCheckedContinuation { cont in
                if Task.isCancelled {
                    cont.resume(returning: false)
                    return
                }
                state.withCriticalRegion { state in
                    switch state {
                    case .idle:
                        handleBuffer(&state, event: .added, currentArray: [MachineBufferData(id: id, data: val, cont: cont)])
                    case .awaitingForConsumer(let array):
                        handleBuffer(&state, event: .added, currentArray: array + [MachineBufferData(id: id, data: val, cont: cont)])
                    case .awaitingForProducer(let cur, let rest):
                        state = .idle
                        ([cur] + rest).forEach { $0.cont.resume(returning: val) }
                        cont.resume(returning: true)
                    }
                }
            }
        } onCancel: {
            state.withCriticalRegion { state in
                switch state {
                case .idle, .awaitingForProducer:
                    break // do nothing, as there is no continuation to be resumed
                case .awaitingForConsumer(let array):
                    let currentArray = array.filter { data in
                        if data.id != id {
                            return true
                        } else {
                            data.cont.resume(returning: false)
                            return false
                        }
                    }
                    handleBuffer(&state, event: .removed(isConsumed: false), currentArray: currentArray)
                }
            }
        }
    }
    
    private func handleBuffer(_ state: inout ChannelState<T>, event: MachineBufferEvent, currentArray: [MachineBufferData<T>]) {
        let bufferedArray = bufferStrategy.bufferReducer(currentArray, event, logger, machineId)
        
        let withoutDuplicated: [MachineBufferData<T>] = bufferedArray.reduce([]) { partialResult, element in
            partialResult.contains(element) ? partialResult : partialResult + [element]
        }
        
        let difference = Set(currentArray).symmetricDifference(Set(withoutDuplicated))
        state = withoutDuplicated.isEmpty ? .idle : .awaitingForConsumer(withoutDuplicated)
        difference.forEach { $0.cont.resume(returning: false) }
    }
}

final class Channel<T: Sendable, Loggable: Sendable>: Sendable, AsyncSequence {
    typealias AsyncIterator = ChannelIterator<T, Loggable>
    typealias Element = T
    
    private let iterator: ChannelIterator<T, Loggable>
    
    init(bufferStrategy: MachineBufferStrategy<T, Loggable>, logger: MachineLogger<Loggable>, machineId: String) {
        self.iterator = ChannelIterator<T, Loggable>(bufferStrategy: bufferStrategy, logger: logger, machineId: machineId)
    }
    
    func makeAsyncIterator() -> ChannelIterator<T, Loggable> { iterator }
    
    @Sendable
    func yield(_ val: T) async -> Bool {
        await iterator.yield(val)
    }
}


enum ChannelState<T: Sendable>: Sendable {
    case idle
    case awaitingForProducer(cur: ChannelConsumer<T>, rest: [ChannelConsumer<T>])
    case awaitingForConsumer([MachineBufferData<T>])
}


struct ChannelConsumer<T: Sendable>: Sendable {
    let id: String
    let cont: CheckedContinuation<T?, Never>
}
