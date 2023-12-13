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
    @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
        _ output: Output,
        _ send: MachineCallback<Input>,
        _ machineId: String,
        _ logger: MachineLogger
    ) async -> Bool
) -> Process<Input> {
    let ipipe = Channel<Input>(bufferStrategy: inputBufferStrategy ?? machine.inputBufferStrategy, logger: logger, machineId: machine.id)
    let opipe = Channel<Output>(bufferStrategy: outputBufferStrategy ?? machine.outputBufferStrategy, logger: logger, machineId: machine.id)
    
    let icallback = MachineCallback(ipipe.yield(_:))
    
    let task = Task(priority: nil) {
        if Task.isCancelled {
            return
        }
        
        let object = machine.onCreate(machine.id, logger)
        
        await machine.onChange(object, MachineCallback(opipe.yield(_:)))
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for await input in ipipe {
                    await machine.onProcess(object, input)
                }
            }
            
            group.addTask {
                for await output in opipe {
                    let isDone = await onConsume(
                        output,
                        icallback,
                        machine.id,
                        logger
                    )
                    if isDone {
                        break
                    }
                }
            }
            
            await group.next()
            group.cancelAll()
        }
        
        
        await machine.onChange(object, nil)
    }
    
    return (
        id: machine.id,
        cancel: { task.cancel() },
        send: icallback
    )
}
