//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//

public final class Process<Input: Sendable, Output: Sendable, State: Sendable>: Sendable {
    
    private let task: Task<Void, Never>
    private let sink: @Sendable (Input) -> Void
    
    internal init(
        machine: Machine<Input, Output, State>,
        state: State,
        onConsume: @escaping @Sendable (Output, @Sendable (Input) -> Void) -> Void
    ) {
        
        let (istream, isink) = streamsink(strategy: machine.iBufferStrategy)
        let (ostream, osink) = streamsink(strategy: machine.oBufferStrategy)
        
        sink = isink
        task = Task.detached(priority: nil) {
            let object = machine.onInitial(state, osink)
            async let ipipe: Void = {
                for await input in istream {
                    await machine.onProcess(object, input)
                }
            }()
            async let opipe: Void = {
                for await output in ostream {
                    onConsume(output, isink)
                }
            }()
            
            _ = await [ipipe, opipe]
        }
    }
    
    deinit {
        task.cancel()
    }
    
    
    public func send(_ input: Input) {
        sink(input)
    }
}

extension Process: Equatable {
    public static func == (lhs: Process<Input, Output, State>, rhs: Process<Input, Output, State>) -> Bool {
        lhs === rhs
    }
}

extension Process: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

fileprivate func streamsink<T>(strategy: MachineBufferStrategy<T>) -> (CustomStream<T>, @Sendable (T) -> Void) {
    let stream = CustomStream<T>(strategy.reducer)
    let sink: @Sendable (T) -> Void = {
        stream.makeAsyncIterator().send($0)
    }
    
    return (stream, sink)
}
