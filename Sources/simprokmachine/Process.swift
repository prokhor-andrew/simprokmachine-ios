//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//


public final class Process<Input: Sendable, Output: Sendable>: Sendable {
    
    private let task: Task<Void, Never>
    private let pipe: Channel<Input>
    
    internal init<Object: Actor>(
        object: Object,
        machine: Machine<Input, Output>,
        onConsume: @escaping @Sendable (isolated Object, Output) -> Void
    ) {
        let ipipe = Channel<Input>()
        let opipe = Channel<Output>()
        
        pipe = ipipe
        task = Task(priority: nil) {
            if Task.isCancelled {
                return
            }
            
            let processed = machine.onCreate()
            
            await machine.onChange(processed, opipe.yield(_:))
            
            await {
                async let i: Void = {
                    for await input in ipipe {
                        await machine.onProcess(processed, input)
                    }
                }()
                
                async let o: Void = { [weak object] in
                    for await output in opipe {
                        guard let object else { continue }
                        await onConsume(object, output)
                    }
                }()
                
                
                _ = await [i, o]
            }()
            
            await machine.onChange(processed, nil)
        }
    }
    
    deinit {
        task.cancel()
    }
    
    public func send(_ input: Input) async {
        await pipe.yield(input)
    }
    
    public func callAsFunction(_ input: Input) async {
        await send(input)
    }
}

extension Process: Equatable {
    public static func == (lhs: Process<Input, Output>, rhs: Process<Input, Output>) -> Bool {
        lhs === rhs
    }
}

extension Process: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
