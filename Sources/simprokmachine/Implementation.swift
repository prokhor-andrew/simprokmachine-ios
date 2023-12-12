//
//  Implementation.swift
//  SimprokMachineDemo
//
//  Created by Andriy Prokhorenko on 12.12.2023.
//



internal func _run<Input: Sendable, Output: Sendable>(
    machine: Machine<Input, Output>,
    inputBufferStrategy: MachineBufferStrategy<Input>?,
    outputBufferStrategy: MachineBufferStrategy<Output>?,
    logger: MachineLogger,
    @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
) -> Process<Input> {
    let ipipe = Channel<Input>(bufferStrategy: inputBufferStrategy ?? machine.inputBufferStrategy)
    let opipe = Channel<Output>(bufferStrategy: outputBufferStrategy ?? machine.outputBufferStrategy)
    
    let task = Task(priority: nil) {
        if Task.isCancelled {
            return
        }
        
        let object = machine.onCreate(machine.id, logger)
        
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
    
    return (
        task: task,
        send: MachineCallback<Input>(ipipe.yield)
    )
}
