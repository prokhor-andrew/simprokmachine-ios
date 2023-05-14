//
//  Subscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


import Foundation

public final class Subscription<Input, Output> {

    private let machine: Machine<Input, Output>
    private let callback: BiHandler<Output, Handler<Input>>
    private let processQueue: DispatchQueue
    private let outputQueue: DispatchQueue

    internal init(
            machine: Machine<Input, Output>,
            isConsumeOnMain: Bool,
            callback: @escaping BiHandler<Output, Handler<Input>>
    ) {
        func queue(tag: String) -> DispatchQueue {
            DispatchQueue(label: String(describing: Self.self) + "/" + tag, qos: .userInteractive)
        }
        
        // we check that this machine has not been subscribed to
        assert(!subscribed.contains(machine.id), "Machine already subscribed")
        subscribed.insert(machine.id)

        self.processQueue = machine.isProcessOnMain ? .main : queue(tag: "process")
        self.outputQueue = isConsumeOnMain ? .main : queue(tag: "output")
        
        self.machine = machine
        self.callback = callback

        _send(nil)
    }

    deinit {
        subscribed.remove(machine.id)
    }

    public func send(input: Input) {
        _send(input)
    }

    private func _send(_ input: Input?) {
        processQueue.async { [weak self] in
            self?.machine.onProcess(input) { [weak self] output in
                self?.outputQueue.async { [weak self] in
                    guard let send = self?.send else {
                        return
                    }
                    self?.callback(output, send)
                }
            }
        }
    }
}

fileprivate var subscribed: Set<ObjectIdentifier> = []
