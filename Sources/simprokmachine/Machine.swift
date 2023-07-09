//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public struct Machine<Input: Sendable, Output: Sendable>: Sendable {
    
    private final class Id {}
    
    private let _id = ObjectIdentifier(Id())
    
    internal let onCreate: @Sendable () -> Actor
    internal let onChange: @Sendable (isolated Actor, (@Sendable (Output) async -> Void)?) async -> Void
    internal let onProcess: @Sendable (isolated Actor, Input) async -> Void
    
    public init<Object: Actor>(
        _ object: @escaping @Sendable () -> Object,
        onChange: @escaping @Sendable (isolated Object, (@Sendable (Output) async -> Void)?) -> Void,
        onProcess: @escaping @Sendable (isolated Object, Input) -> Void
    ) {
        self.onCreate = object
        self.onChange = {
            await onChange($0 as! Object, $1)
        }
        self.onProcess = {
            await onProcess($0 as! Object, $1)
        }
    }
    
    public var id: String {
        "\(_id)"
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

public extension Actor {

    func run<Input: Sendable, Output: Sendable>(
        _ machine: Machine<Input, Output>,
        onConsume: @escaping @Sendable (isolated Self, Output) -> Void
    ) -> Process<Input, Output> {
        Process(object: self, machine: machine, onConsume: onConsume)
    }
}
