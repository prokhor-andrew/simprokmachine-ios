//
//  ChildSubscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class ChildSubscription<Input>: BaseSubscription<Input> {
    
    private let setter: Handler<Input?>
    private let processQueue: DispatchQueue
    private let outQueue: DispatchQueue
    
    internal init<M: ChildMachine>(
        _ machine: M,
        _ callback: @escaping Handler<M.Output>
    ) where M.Input == Input {
        switch machine.queue {
        case .new:
            self.processQueue = DispatchQueue(Self.self, tag: "process")
        case .main:
            self.processQueue = DispatchQueue.main
        }
        self.outQueue = DispatchQueue(Self.self, tag: "output")
        self.setter = { [weak machine, weak outQueue] input in
            if let machine = machine {
                machine.process(input: input) { [weak outQueue] output in
                    outQueue?.async {
                        callback(output)
                    }
                }
            } else {
                // do nothing
            }
        }
        super.init(machine: nil)
     
        processQueue.async { [weak self] in
            self?.setter(nil)
        }
    }
    
    internal override func set(input: Input) {
        processQueue.async { [weak self] in
            self?.setter(input)
        }
    }
}
