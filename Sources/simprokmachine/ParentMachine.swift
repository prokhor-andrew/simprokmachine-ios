//
//  ParentMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.


public final class ParentMachine<Input, Output>: Automaton {

    private let machine: AnyObject

    public let isProcessOnMain: Bool

    private let _onProcess: BiHandler<Input?, Handler<Output>>
    private let _onClearUp: Action

    public init<M: Automaton>(_ machine: M) where M.Input == Input, M.Output == Output {
        self.machine = machine
        self.isProcessOnMain = machine.isProcessOnMain
        self._onProcess = machine.onProcess(input:callback:)
        self._onClearUp = machine.onClearUp
    }

    public func onProcess(input: Input?, callback: @escaping Handler<Output>) {
        _onProcess(input, callback)
    }

    public func onClearUp() {
        _onClearUp()
    }

    public func isEqual<M: Automaton>(to object: M) -> Bool where M.Input == Input, M.Output == Output {
        object === machine
    }

    public func isNotEqual<M: Automaton>(to object: M) -> Bool where M.Input == Input, M.Output == Output {
        !isEqual(to: object)
    }
}
