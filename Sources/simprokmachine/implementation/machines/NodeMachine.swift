//
//  NodeMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class NodeMachine<Input, Output>: RootMachine {
    
    private let emitter: EmitterMachine<Input, Output> = EmitterMachine()
    private var subscription: Subscription?
    
    internal let child: Machine<EmitterInput<Input>, Output>
    
    internal init(
        machine: Machine<Input, Output>,
        callback: @escaping Handler<Output>
    ) {
        self.child = Machine.merge(
            emitter.machine,
            machine
                .outward { .set(.fromConnected($0)) }
                .inward { .set($0.value) }
        ).redirect { output in
            switch output {
            case .toConnected(let input):
                return .back(.init(input))
            case .fromConnected:
                return .prop
            }
        }.outward { output in
            switch output {
            case .toConnected:
                return .set()
            case .fromConnected(let output):
                return .set(output)
            }
        }
        
        self.subscription = start(callback: callback)
    }
    
    deinit {
        subscription = nil
    }
    
    func send(_ val: Input) {
        emitter.send(val)
    }
}
