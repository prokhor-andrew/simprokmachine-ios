//
//  Subscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.


public final class Subscription<Input, Output> {

    private let machine: Machine<Input, Output>
    private let callback: BiHandler<Output, Handler<Input>>

    internal init(
            machine: Machine<Input, Output>,
            callback: @escaping BiHandler<Output, Handler<Input>>
    ) {
        // we check that this machine has not been subscribed to
        assert(!subscribed.contains(machine.id), "Machine already subscribed")
        subscribed.insert(machine.id)

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
        machine.processQueue.async { [weak self] in
            self?.machine.onProcess(input) { [weak self] output in
                self?.machine.outputQueue.async { [weak self] in
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
