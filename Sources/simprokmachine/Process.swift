//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//


public final class Process<Input: Sendable, Output: Sendable>: Sendable {
    
    private let task: Task<Void, Never>
    private let pipe: Channel<Input>
    
    internal init(
        _id: String,
        machine: Machine<Input, Output>,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
    ) {
        id = _id
        
        let ipipe = Channel<Input>()
        let opipe = Channel<Output>()
        
        pipe = ipipe
        task = Task(priority: nil) {
            if Task.isCancelled {
                return
            }
            
            let object = machine.onCreate()
            
            await machine.onChange(object, opipe.yield(_:))
            
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
    
    public func send(_ input: Input) async {
        await pipe.yield(input)
    }
    
    public func callAsFunction(_ input: Input) async {
        await send(input)
    }
}

extension Process: Equatable {
    public static func == (lhs: Process<Input, Output>, rhs: Process<Input, Output>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Process: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
