//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//


public final class Process<Input: Sendable, Output: Sendable, Message>: Sendable {
    
    private let task: Task<Void, Never>
    private let pipe: Channel<Input>
    
    internal init(
        _id: String,
        logger: @escaping (Message) -> Void,
        iBufferStrategy: MachineBufferStrategy<Input>?,
        oBufferStrategy: MachineBufferStrategy<Output>?,
        machine: Machine<Input, Output, Message>,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
    ) {
        id = _id
        
        let ipipe = Channel<Input>(bufferStrategy: iBufferStrategy ?? machine.inputBufferStrategy)
        let opipe = Channel<Output>(bufferStrategy: oBufferStrategy ?? machine.outputBufferStrategy)
        
        pipe = ipipe
        task = Task(priority: nil) {
            if Task.isCancelled {
                return
            }
            
            let object = machine.onCreate(logger)
            
            await machine.onChange(object, MachineCallback(opipe.yield(_:)))
            
            await {
                async let i: Void = {
                    for await input in ipipe {
                        await machine.onProcess(object, input)
                    }
                }()
                
                async let o: Void = {
                    for await output in opipe {
                        await onConsume(output)
                    }
                }()
                
                
                _ = await [i, o]
            }()
            
            await machine.onChange(object, nil)
        }
    }
    
    deinit {
        task.cancel()
    }
    
    public let id: String
    
    @discardableResult
    public func send(_ input: Input) async -> Bool {
        await pipe.yield(input)
    }
    
    @discardableResult
    public func callAsFunction(_ input: Input) async -> Bool {
        await send(input)
    }
}

extension Process: Equatable {
    public static func == (lhs: Process<Input, Output, Message>, rhs: Process<Input, Output, Message>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Process: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
