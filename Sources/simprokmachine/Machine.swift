//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.

import Foundation

public struct Machine<Input, Output> {

    internal let id: ObjectIdentifier
    internal let onProcess: BiHandler<Input?, Handler<Output>>
    internal let processQueue: DispatchQueue
    internal let outputQueue: DispatchQueue

    public init<Object: AnyObject>(
            _ object: Object,
            isProcessOnMain: Bool = false,
            onProcess: @escaping TriHandler<Object, Input?, Handler<Output>>
    ) {
        func queue(tag: String) -> DispatchQueue {
            DispatchQueue(label: String(describing: Self.self) + "/" + tag, qos: .userInteractive)
        }

        processQueue = isProcessOnMain ? .main : queue(tag: "process")
        outputQueue = queue(tag: "output")

        id = ObjectIdentifier(object)
        self.onProcess = { [object] input, callback in
            onProcess(object, input, callback)
        }
    }

    public func subscribe(_ callback: @escaping BiHandler<Output, Handler<Input>>) -> Subscription<Input, Output> {
        Subscription(machine: self, callback: callback)
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

    init(isProcessOnMain: Bool = false,
         onProcess: @escaping BiHandler<Input?, Handler<Output>>
    ) {
        self.init(Dummy(), isProcessOnMain: isProcessOnMain, onProcess: { _, input, callback in
            onProcess(input, callback)
        })
    }
}
