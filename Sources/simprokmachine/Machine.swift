//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.

import Foundation


public class Machine<Input: Sendable, Output: Sendable> {

    private let id: ObjectIdentifier
    private let onProcess: BiHandler<Input?, Handler<Output>>
    private let isProcessOnMain: Bool
    
    private var sub: Subscription<Input, Output>?
    
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
    
    @discardableResult
    public func start(
        isConsumeOnMain: Bool = false,
        onConsume: @escaping BiHandler<Output, Handler<Input>>
    ) -> Bool {
        if sub != nil {
            return false
        }
        
        sub = Subscription(
            isProcessOnMain: isProcessOnMain,
            isConsumeOnMain: isConsumeOnMain,
            onProcess: onProcess,
            onConsume: onConsume
        )
        
        return true
    }
    
    @discardableResult
    public func stop() -> Bool {
        if sub == nil {
            return false
        }
        
        sub = nil
        
        return true
    }
    
    public func started(
        isConsumeOnMain: Bool,
        onConsume: @escaping BiHandler<Output, Handler<Input>>
    ) -> Machine<Input, Output> {
        start(isConsumeOnMain: isConsumeOnMain, onConsume: onConsume)
        return self
    }
    
    public func stopped() -> Machine<Input, Output> {
        stop()
        return self
    }
    
    @discardableResult
    public func send(input: Input) -> Bool {
        sub?.send(input: input)
        return sub != nil
    }
    
    public var isRunning: Bool {
        sub != nil
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

    convenience init(
        isProcessOnMain: Bool = false,
        onProcess: @escaping BiHandler<Input?, Handler<Output>>
    ) {
        self.init(Dummy(), isProcessOnMain: isProcessOnMain, onProcess: { _, input, callback in
            onProcess(input, callback)
        })
    }
}

private final class Subscription<Input, Output> {

    private let processQueue: DispatchQueue
    private let outputQueue: DispatchQueue

    private let onProcess: BiHandler<Input?, Handler<Output>>
    private let onConsume: BiHandler<Output, Handler<Input>>
    
    internal init(
        isProcessOnMain: Bool,
        isConsumeOnMain: Bool,
        onProcess: @escaping BiHandler<Input?, Handler<Output>>,
        onConsume: @escaping BiHandler<Output, Handler<Input>>
    ) {
        func queue(tag: String) -> DispatchQueue {
            DispatchQueue(label: String(describing: Self.self) + "/" + tag, qos: .userInteractive)
        }

        self.processQueue = isProcessOnMain ? .main : queue(tag: "process")
        self.outputQueue = isConsumeOnMain ? .main : queue(tag: "output")
        
        self.onProcess = onProcess
        self.onConsume = onConsume

        _send(nil)
    }

    internal func send(input: Input) {
        _send(input)
    }

    private func _send(_ input: Input?) {
        processQueue.async { [weak self] in
            self?.onProcess(input) { [weak self] output in
                self?.outputQueue.async { [weak self] in
                    guard let send = self?.send else {
                        return
                    }
                    self?.onConsume(output, send)
                }
            }
        }
    }
}
