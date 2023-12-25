//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 13.12.2023.
//


public extension Machine {
    
    
    func run(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineLogger
        ) -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: onConsume
        )
    }
    
    func run(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String
        ) -> Void
    ) -> Process<Input> {
        run(
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: MachineLogger.default, 
            onConsume: { output, id, _ in onConsume(output, id) }
        )
    }
}
