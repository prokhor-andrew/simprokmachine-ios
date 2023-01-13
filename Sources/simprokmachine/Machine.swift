//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.



public final class Machine<Input, Output>: Automaton {
    
    public let isProcessOnMain: Bool
    
    private let _onProcess: BiHandler<Input?, Handler<Output>>
    private let _onClearUp: Action
    
    public init(
        isProcessOnMain: Bool,
        onProcess: @escaping BiHandler<Input?, Handler<Output>>,
        onClearUp: @escaping Action
    ) {
        self.isProcessOnMain = isProcessOnMain
        self._onProcess = onProcess
        self._onClearUp = onClearUp
    }
    
    public func onProcess(input: Input?, callback: @escaping Handler<Output>) {
        _onProcess(input, callback)
    }
    
    public func onClearUp() {
        _onClearUp()
    }
}
