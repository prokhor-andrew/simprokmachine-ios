//
//  Subscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation

/// Keep the instance of this object in order to keep the flow running
public class Subscription<Input, Output> {
    
    private let machine: AnyObject
    private let onProcess: BiHandler<Input?, Handler<Output>>
    private let onClearUp: Action
    private let processQueue: DispatchQueue
    
    private let callback: BiHandler<Output, Handler<Input>>
    private let outputQueue: DispatchQueue
    
    
    internal init<M: Machine>(
        machine: M,
        callback: @escaping BiHandler<Output, Handler<Input>>
    ) where M.Input == Input, M.Output == Output {
        // we check that this machine has not been subscribed to
        assert(!subscribedToMachines.contains(ObjectIdentifier(machine)))
        
        subscribedToMachines.insert(ObjectIdentifier(machine))
        
        self.machine = machine
        self.onProcess = machine.onProcess(input:callback:)
        self.onClearUp = machine.onClearUp
        self.processQueue = machine.isProcessOnMain ? DispatchQueue.main : DispatchQueue(Self.self, tag: "process")
        
        self.outputQueue = DispatchQueue(Self.self, tag: "output")
        self.callback = callback
        

        _send(input: nil)
    }
    
    deinit {
        subscribedToMachines.remove(ObjectIdentifier(machine))
        onClearUp()
    }
    
    public func send(input: Input) {
        _send(input: input)
    }
    
    
    private func _send(input: Input?) {
        processQueue.async { [weak self] in
            self?.onProcess(input) { [weak self] output in
                self?.outputQueue.async { [weak self] in
                    guard let send = self?.send else { return }
                    self?.callback(output, send)
                }
           }
        }
    }
}


fileprivate extension DispatchQueue {
    
    convenience init<T>(_ type: T.Type, tag: String) {
        self.init(label: String(describing: T.self) + "/" + tag, qos: .userInteractive)
    }
}


fileprivate var subscribedToMachines: Set<ObjectIdentifier> = []
