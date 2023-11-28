//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable>: Sendable, Identifiable {
    
    internal let onCreate: @Sendable (String, @escaping (Loggable) -> Void) -> Actor
    internal let onChange: @Sendable (isolated Actor, String, MachineCallback<Output>?) async -> Void
    internal let onProcess: @Sendable (isolated Actor, String, Input) async -> Void
    
    internal let inputBufferStrategy: MachineBufferStrategy<Input>
    internal let outputBufferStrategy: MachineBufferStrategy<Output>
    
    public let id: String = .id
        
    public init<Object: Actor>(
        onCreate: @escaping @Sendable (String, @escaping (Loggable) -> Void) -> Object,
        onChange: @escaping @Sendable (isolated Object, String, MachineCallback<Output>?) async -> Void,
        onProcess: @escaping @Sendable (isolated Object, String, Input) async -> Void,
        inputBufferStrategy: MachineBufferStrategy<Input> = .default,
        outputBufferStrategy: MachineBufferStrategy<Output> = .default
    ) {
        self.inputBufferStrategy = inputBufferStrategy
        self.outputBufferStrategy = outputBufferStrategy
        self.onCreate = onCreate
        self.onChange = {
            await onChange($0 as! Object, $1, $2)
        }
        self.onProcess = {
            await onProcess($0 as! Object, $1, $2)
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

public extension Machine {
    
    func run(
        inputBufferStrategy: MachineBufferStrategy<Input>? = nil,
        outputBufferStrategy: MachineBufferStrategy<Output>? = nil,
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void,
        logger: @escaping (Loggable) -> Void
    ) -> Process<Input, Output> {
        Process(
            logger: logger,
            iBufferStrategy: inputBufferStrategy,
            oBufferStrategy: outputBufferStrategy,
            machine: self,
            onConsume: onConsume
        )
    }
}
