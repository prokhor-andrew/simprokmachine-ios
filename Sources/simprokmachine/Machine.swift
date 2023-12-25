//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable>: Sendable, Identifiable {
    
    internal let onCreate: @Sendable (String, MachineLogger) -> (
        onChange: @Sendable (MachineCallback<Output>?) async -> Void,
        onProcess: @Sendable (Input) async -> Void
    )
    
    internal let inputBufferStrategy: MachineBufferStrategy<Input>
    internal let outputBufferStrategy: MachineBufferStrategy<Output>
    
    public let id: String = .id
        
    public init<Object: Actor>(
        onCreate: @escaping @Sendable (String, MachineLogger) -> Object,
        onChange: @escaping @Sendable (isolated Object, MachineCallback<Output>?) -> Void,
        onProcess: @escaping @Sendable (isolated Object, Input) -> Void,
        inputBufferStrategy: MachineBufferStrategy<Input> = .default,
        outputBufferStrategy: MachineBufferStrategy<Output> = .default
    ) {
        
        self.inputBufferStrategy = inputBufferStrategy
        self.outputBufferStrategy = outputBufferStrategy
        self.onCreate = { id, logger in
            let object = onCreate(id, logger)
            return (
                onChange: { callback in
                    await onChange(object, callback)
                },
                onProcess: { input in
                    await onProcess(object, input)
                }
            )
        }
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
