//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 13.12.2023.
//


public extension Machine {
    
    @discardableResult
    func runUntilWithIdSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineCallback<Input>,
            MachineLogger
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: onConsume
        )
    }
    
    
    @discardableResult
    func runWithIdSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineCallback<Input>,
            MachineLogger
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, id, send, logger)
                return false
            }
        )
    }

    
    @discardableResult
    func runUntilWithidSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineCallback<Input>
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output, id, send)
            }
        )
    }
    
    @discardableResult
    func runUntilWithId(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineLogger
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, id, logger)
            }
        )
    }
    
    @discardableResult
    func runUntilWithSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            MachineCallback<Input>,
            MachineLogger
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, send, logger)
            }
        )
    }
    
    
    @discardableResult
    func runWithIdSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineCallback<Input>
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output, id, send)
                return false
            }
        )
    }
    
    @discardableResult
    func runWithId(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String,
            MachineLogger
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, id, logger)
                return false
            }
        )
    }
    
    @discardableResult
    func runUntilWithId(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output, id)
            }
        )
    }
    
    @discardableResult
    func runWithSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            MachineCallback<Input>,
            MachineLogger
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, send, logger)
                return false
            }
        )
    }
    
    @discardableResult
    func runUntilWithSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            MachineCallback<Input>
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output, send)
            }
        )
    }
    
    @discardableResult
    func runUntil(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            MachineLogger
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, logger)
            }
        )
    }
    
    @discardableResult
    func runUntil(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output
        ) async -> Bool
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output)
            }
        )
    }

    
    @discardableResult
    func runWithId(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            String
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output, id)
                return false
            }
        )
    }
    
    @discardableResult
    func runWithSend(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            MachineCallback<Input>
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output, send)
                return false
            }
        )
    }
    
    @discardableResult
    func run(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (
            Output,
            MachineLogger
        ) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: { output, id, send, logger in
                await onConsume(output, logger)
                return false
            }
        )
    }
    
    @discardableResult
    func run(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: .default,
            onConsume: { output, id, send, logger in
                await onConsume(output)
                return false
            }
        )
    }
}
