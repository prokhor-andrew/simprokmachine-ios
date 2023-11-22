//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable>: Sendable {
    
    internal let onCreate: @Sendable () -> Actor
    internal let onChange: @Sendable (isolated Actor, MachineCallback<Output>?) async -> Void
    internal let onProcess: @Sendable (isolated Actor, Input) async -> Void
    
    internal let inputBufferStrategy: MachineBufferStrategy<Input>
    internal let outputBufferStrategy: MachineBufferStrategy<Output>
    
    public let id: String = .id
    
    public init<Object: Actor>(
        _ object: @escaping @Sendable () -> Object,
        onChange: @escaping @Sendable (isolated Object, MachineCallback<Output>?) -> Void,
        onProcess: @escaping @Sendable (isolated Object, Input) async -> Void,
        inputBufferStrategy: MachineBufferStrategy<Input> = .default,
        outputBufferStrategy: MachineBufferStrategy<Output> = .default
    ) {
        self.inputBufferStrategy = inputBufferStrategy
        self.outputBufferStrategy = outputBufferStrategy
        self.onCreate = object
        self.onChange = {
            await onChange($0 as! Object, $1)
        }
        self.onProcess = {
            await onProcess($0 as! Object, $1)
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
        @_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void
    ) -> Process<Input, Output> {
        Process(
            _id: id,
            iBufferStrategy: inputBufferStrategy,
            oBufferStrategy: outputBufferStrategy,
            machine: self,
            onConsume: onConsume
        )
    }
}
