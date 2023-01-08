//
//  ParentAutomaton.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.


public final class ParentAutomaton<Input, Output>: Machine {
    
    private let machine: AnyObject
    
    public let isProcessOnMain: Bool
    
    private let _onProcess: BiHandler<Input?, Handler<Output>>
    private let _onClearUp: Action
    
    public init<M: Machine>(_ machine: M) where M.Input == Input, M.Output == Output {
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
}
