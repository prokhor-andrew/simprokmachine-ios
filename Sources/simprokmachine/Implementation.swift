//
//  Implementation.swift
//  SimprokMachineDemo
//
//  Created by Andriy Prokhorenko on 12.12.2023.
//



internal func _run<Input: Sendable, Output: Sendable, Loggable: Sendable>(
    machine: Machine<Input, Output, Loggable>,
    inputBufferStrategy: MachineBufferStrategy<Input, Loggable>?,
    outputBufferStrategy: MachineBufferStrategy<Output, Loggable>?,
    logger: MachineLogger<Loggable>,
    @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
) -> Process<Input> {
    let ipipe = Channel<Input, Loggable>(bufferStrategy: inputBufferStrategy ?? machine.inputBufferStrategy, logger: logger, machineId: machine.id)
    let opipe = Channel<Output, Loggable>(bufferStrategy: outputBufferStrategy ?? machine.outputBufferStrategy, logger: logger, machineId: machine.id)
    
    let icallback = MachineCallback(ipipe.yield(_:))
    
    let task = Task(priority: nil) {
        if Task.isCancelled {
            return
        }
        
        let (onChange, onProcess) = machine.onCreate(machine.id, logger)
        
        await onChange(MachineCallback(opipe.yield(_:)))
        
        await withTaskGroup(of: Void.self) { group in
            let isInputCancelled = group.addTaskUnlessCancelled {
                for await input in ipipe {
                    await onProcess(input)
                }
            }
            
            if !isInputCancelled {
                group.cancelAll()
                return
            }
            
            let isOutputCancelled = group.addTaskUnlessCancelled {
                for await output in opipe {
                    await onConsume(output)
                }
            }
            
            if !isOutputCancelled {
                group.cancelAll()
                return
            }
            
            await group.next()
            group.cancelAll()
        }
        
        
        await onChange(nil)
    }
    
    return Process(
        id: machine.id,
        cancel: { task.cancel() },
        send: icallback
    )
}
