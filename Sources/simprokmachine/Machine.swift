//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.

public struct Machine<Input, Output> {

    internal let isProcessOnMain: Bool
    internal let onProcess: BiHandler<Input?, Handler<Output>>
    internal let onClearUp: Action

    public init(
            isProcessOnMain: Bool = false,
            onProcess: @escaping BiHandler<Input?, Handler<Output>>,
            onClearUp: @escaping Action = {}
    ) {
        self.isProcessOnMain = isProcessOnMain
        self.onProcess = onProcess
        self.onClearUp = onClearUp
    }

    public func subscribe(_ callback: @escaping BiHandler<Output, Handler<Input>>) -> Subscription<Input, Output> {
        Subscription(machine: self, callback: callback)
    }
}

public extension Machine {

    init(_ machine: Machine<Input, Output>) {
        self.init(isProcessOnMain: machine.isProcessOnMain, onProcess: machine.onProcess, onClearUp: machine.onClearUp)
    }
}

public extension Machine {

    init<Object: AnyObject>(
            _ object: Object,
            isProcessOnMain: Bool = false,
            onProcess: @escaping TriHandler<Object, Input?, Handler<Output>>,
            onClearUp: @escaping Handler<Object> = { _ in }
    ) {
        self.init(isProcessOnMain: isProcessOnMain, onProcess: { [object] input, callback in
            onProcess(object, input, callback)
        }, onClearUp: { [object] in
            onClearUp(object)
        });
    }
}