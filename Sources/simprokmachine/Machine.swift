//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable>: Sendable, Identifiable {
    
    public let onCreate: @Sendable (String, MachineLogger) -> (
        onChange: @Sendable (MachineCallback<Output>?) async -> Void,
        onProcess: @Sendable (Input) async -> Void
    )
    
    public let inputBufferStrategy: MachineBufferStrategy<Input>
    public let outputBufferStrategy: MachineBufferStrategy<Output>
    
    public let id: String
    
    public init(
        id: String,
        inputBufferStrategy: MachineBufferStrategy<Input>,
        outputBufferStrategy: MachineBufferStrategy<Output>,
        onCreate: @Sendable @escaping (String, MachineLogger) -> (
            onChange: @Sendable (MachineCallback<Output>?) async -> Void,
            onProcess: @Sendable (Input) async -> Void
        )
    ) {
        self.id = id
        self.inputBufferStrategy = inputBufferStrategy
        self.outputBufferStrategy = outputBufferStrategy
        self.onCreate = onCreate
    }
    
    public init<Object: Actor>(
        onCreate: @escaping @Sendable (String, MachineLogger) -> Object,
        onChange: @escaping @Sendable (isolated Object, MachineCallback<Output>?) -> Void,
        onProcess: @escaping @Sendable (isolated Object, Input) async -> Void,
        inputBufferStrategy: MachineBufferStrategy<Input> = .default,
        outputBufferStrategy: MachineBufferStrategy<Output> = .default
    ) {
        self.init(
            id: .id,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            onCreate: { id, logger in
                let object = onCreate(id, logger)
                return (
                    onChange: { await onChange(object, $0) },
                    onProcess: { await onProcess(object, $0) }
                )
            }
        )
    }
    
    public func run(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        logger: MachineLogger,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
    ) -> Process<Input> {
        _run(
            machine: self,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy,
            logger: logger,
            onConsume: onConsume
        )
    }
}

extension Machine: Equatable {
    public static func == (lhs: Machine<Input, Output>, rhs: Machine<Input, Output>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Machine: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension Machine: CustomStringConvertible {
    
    public var description: String {
        "Machine<\(Input.self), \(Output.self)> id=\(id)"
    }
}

extension Machine: CustomDebugStringConvertible {
    
    public var debugDescription: String { description }
}
