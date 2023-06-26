//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable, State: Sendable>: Sendable {
    
    private final class Id {}
    
    private let _id = ObjectIdentifier(Id())
    
    internal let iBufferStrategy: MachineBufferStrategy<Input>
    internal let oBufferStrategy: MachineBufferStrategy<Output>
    internal let onInitial: @Sendable (State, @Sendable @escaping (Output) -> Void) -> Actor
    internal let onProcess: @Sendable (isolated Actor, Input) async -> Void
    
    public init<Object: Actor>(
        iBufferStrategy: MachineBufferStrategy<Input>,
        oBufferStrategy: MachineBufferStrategy<Output>,
        onInitial: @escaping @Sendable (State, @Sendable @escaping (Output) -> Void) -> Object,
        onProcess: @escaping @Sendable (isolated Object, Input) -> Void
    ) {
        self.iBufferStrategy = iBufferStrategy
        self.oBufferStrategy = oBufferStrategy
        self.onInitial = onInitial
        self.onProcess = {
            await onProcess($0 as! Object, $1)
        }
    }
    
    public func run(
        _ state: State,
        onConsume: @escaping @Sendable (Output, @Sendable (Input) -> Void) -> Void
    ) -> Process<Input, Output, State> {
        Process(machine: self, state: state, onConsume: onConsume)
    }
    
    public var id: String {
        "\(_id)"
    }
}

extension Machine: Equatable {
    public static func == (lhs: Machine<Input, Output, State>, rhs: Machine<Input, Output, State>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Machine: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension Machine {
    
    private actor Dummy<T> {
        let callback: @Sendable (T) -> Void
        
        init(_ callback: @Sendable @escaping (T) -> Void) {
            self.callback = callback
        }
    }
    
    init(
        iBufferStrategy: MachineBufferStrategy<Input>,
        oBufferStrategy: MachineBufferStrategy<Output>,
        onInitial: @escaping @Sendable (State, @Sendable @escaping (Output) -> Void) -> Void,
        onProcess: @escaping @Sendable (Input, @Sendable @escaping (Output) -> Void) -> Void
    ) {
        self.init(
            iBufferStrategy: iBufferStrategy,
            oBufferStrategy: oBufferStrategy,
            onInitial: { state, callback in
                onInitial(state, callback)
                return Dummy<Output>(callback)
            },
            onProcess: { object, input in
                onProcess(input, object.callback)
            }
        )
    }
}
