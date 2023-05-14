//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.



public struct Machine<Input, Output> {

    internal let id: ObjectIdentifier
    internal let onProcess: BiHandler<Input?, Handler<Output>>
    internal let isProcessOnMain: Bool
    
    public init<Object: AnyObject>(
            _ object: Object,
            isProcessOnMain: Bool = false,
            onProcess: @escaping TriHandler<Object, Input?, Handler<Output>>
    ) {
        id = ObjectIdentifier(object)
        self.isProcessOnMain = isProcessOnMain
        self.onProcess = { [object] input, callback in
            onProcess(object, input, callback)
        }
    }

    public func subscribe(
        isConsumeOnMain: Bool = false,
        callback: @escaping BiHandler<Output, Handler<Input>>
    ) -> Subscription<Input, Output> {
        Subscription(machine: self, isConsumeOnMain: isConsumeOnMain, callback: callback)
    }
}

extension Machine: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func ==(lhs: Machine<Input, Output>, rhs: Machine<Input, Output>) -> Bool {
        lhs.id == rhs.id
    }
}

public extension Machine {

    private class Dummy {
    }

    init(
        isProcessOnMain: Bool = false,
        onProcess: @escaping BiHandler<Input?, Handler<Output>>
    ) {
        self.init(Dummy(), isProcessOnMain: isProcessOnMain, onProcess: { _, input, callback in
            onProcess(input, callback)
        })
    }
}
