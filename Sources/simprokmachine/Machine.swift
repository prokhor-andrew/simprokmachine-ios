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
    
    public var id: String { "\(_id)" }
    
    public init<Object: Actor>(
        _ object: @escaping @Sendable () -> Object,
        onChange: @escaping @Sendable (isolated Object, (@Sendable (Output) async -> Void)?) -> Void,
        onProcess: @escaping @Sendable (isolated Object, Input) async -> Void
    ) {
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
    
    func run(@_inheritActorContext @_implicitSelfCapture onConsume: @escaping @Sendable (Output) async -> Void) -> Process<Input, Output> {
        Process(_id: id, machine: self, onConsume: onConsume)
    }
}
