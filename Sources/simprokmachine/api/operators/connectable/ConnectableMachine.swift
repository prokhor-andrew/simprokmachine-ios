//
//  ConnectableMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// The machine for dynamic creation and connection of other machines
public final class ConnectableMachine<C: Connection>: ChildMachine {
    public typealias Input = C.Input
    public typealias Output = C.Output
    
    private var dictionary: [ObjectIdentifier: NodeMachine<C.Input, C.Output>] = [:]
    
    private var state: C
    
    private let reducer: BiMapper<C, C.Input, ConnectionType<C>>
    
    /// `ChildMachine` protocol property
    public var queue: MachineQueue { .new }
    
    
    /// - parameter initial: initial state. After subscription to the `ConnectableMachine` all the `machines` in `initial` object will be connected and subscribed to.
    /// - parameter reducer: reducer method that is triggered every time input is received by `ConnectableMachine`.
    /// Accepts current state, incoming input and returns an object of `ConnectionType<C>` type.
    /// Either new `machines` are connected to the `ConnectableMachine` or current `machines` receive input, depending on the returned value.
    public init(
        _ initial: C,
        reducer: @escaping BiMapper<C, C.Input, ConnectionType<C>>
    ) {
        self.state = initial
        self.reducer = reducer
    }
    
    /// `ChildMachine` protocol method
    public func process(input: Input?, callback: @escaping Handler<Output>) {
        if let input = input {
            let result = reducer(state, input)
            switch result {
            case .reduce(let connection):
                state = connection
                connect(callback: callback)
            case .inward:
                send(input)
            }
        } else {
            connect(callback: callback)
        }
    }
    
    
    private func connect(callback: @escaping Handler<Output>) {
        dictionary = state.machines.reduce([:], { cur, machine in
            let id = ObjectIdentifier(machine)
            if cur[id] != nil {
                return cur
            } else {
                if let item = dictionary[id] {
                    return cur.copyAdd(key: id, element: item)
                } else {
                    return cur.copyAdd(key: id, element: NodeMachine(
                        machine: machine,
                        callback: callback
                    ))
                }
            }
        })
    }
    
    private func send(_ input: C.Input) {
        dictionary.forEach { $1.send(input) }
    }
}
