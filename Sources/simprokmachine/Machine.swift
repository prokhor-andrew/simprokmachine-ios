//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable, Message>: Sendable, Identifiable {
    
    internal let onCreate: @Sendable (@escaping (Message) -> Void) -> Actor
    internal let onChange: @Sendable (isolated Actor, MachineCallback<Output>?) async -> Void
    internal let onProcess: @Sendable (isolated Actor, Input) async -> Void
    
    internal let inputBufferStrategy: MachineBufferStrategy<Input>
    internal let outputBufferStrategy: MachineBufferStrategy<Output>
    
    public let id: String = .id
    
    private init(
        onCreate: @Sendable @escaping (@escaping (Message) -> Void) -> Actor,
        onChange: @Sendable @escaping (isolated Actor, MachineCallback<Output>?) async -> Void,
        onProcess: @Sendable @escaping (isolated Actor, Input) async -> Void,
        inputBufferStrategy: MachineBufferStrategy<Input>,
        outputBufferStrategy: MachineBufferStrategy<Output>
    ) {
        self.onCreate = onCreate
        self.onChange = onChange
        self.onProcess = onProcess
        self.inputBufferStrategy = inputBufferStrategy
        self.outputBufferStrategy = outputBufferStrategy
    }
    
    public init<Object: Actor>(
        onCreate: @escaping @Sendable (@escaping (Message) -> Void) -> Object,
        onChange: @escaping @Sendable (isolated Object, MachineCallback<Output>?) async -> Void,
        onProcess: @escaping @Sendable (isolated Object, Input) async -> Void,
        inputBufferStrategy: MachineBufferStrategy<Input> = .default,
        outputBufferStrategy: MachineBufferStrategy<Output> = .default
    ) {
        self.inputBufferStrategy = inputBufferStrategy
        self.outputBufferStrategy = outputBufferStrategy
        self.onCreate = onCreate
        self.onChange = {
            await onChange($0 as! Object, $1)
        }
        self.onProcess = {
            await onProcess($0 as! Object, $1)
        }
    }
    
    
    public func mapMsg<RMessage>(function: @escaping (Message) -> RMessage) -> Machine<Input, Output, RMessage> {
        Machine<Input, Output, RMessage>(
            onCreate: { logger in onCreate { logger(function($0)) } },
            onChange: onChange,
            onProcess: onProcess,
            inputBufferStrategy: inputBufferStrategy,
            outputBufferStrategy: outputBufferStrategy
        )
    }
}

extension Machine: Equatable {
    public static func == (lhs: Machine<Input, Output, Message>, rhs: Machine<Input, Output, Message>) -> Bool {
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
        logger: @escaping (Message) -> Void
    ) -> Process<Input, Output, Message> {
        Process(
            _id: id,
            logger: logger,
            iBufferStrategy: inputBufferStrategy,
            oBufferStrategy: outputBufferStrategy,
            machine: self,
            onConsume: onConsume
        )
    }
}
