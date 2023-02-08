//
//  Subscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.01.2020.
//  Copyright (c) 2020 simprok. All rights reserved.

import Foundation

public final class Subscription<Input, Output> {

    private let onProcess: BiHandler<Input?, Handler<Output>>
    private let onClearUp: Action
    private let onCallback: BiHandler<Output, Handler<Input>>

    private let processQueue: DispatchQueue
    private let outputQueue: DispatchQueue

    internal init(
            machine: Machine<Input, Output>,
            callback: @escaping BiHandler<Output, Handler<Input>>
    ) {
        onProcess = machine.onProcess
        onClearUp = machine.onClearUp
        onCallback = callback

        processQueue = machine.isProcessOnMain ? DispatchQueue.main : Subscription.queue(tag: "process")
        outputQueue = Subscription.queue(tag: "output")


        _send(nil)
    }

    deinit {
        onClearUp()
    }

    public func send(input: Input) {
        _send(input)
    }

    private func _send(_ input: Input?) {
        processQueue.async { [weak self] in
            self?.onProcess(input) { [weak self] output in
                self?.outputQueue.async { [weak self] in
                    guard let send = self?.send else {
                        return
                    }
                    self?.onCallback(output, send)
                }
            }
        }
    }

    private static func queue(tag: String) -> DispatchQueue {
        DispatchQueue(label: String(describing: Self.self) + "/" + tag, qos: .userInteractive)
    }
}