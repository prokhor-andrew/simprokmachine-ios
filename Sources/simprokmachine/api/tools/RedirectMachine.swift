//
//  RedirectMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.



internal final class RedirectMachine<Input, Output> : ChildMachine {
    internal typealias Input = Input
    internal typealias Output = Output
    
    internal var queue: MachineQueue { .new }
    
    private let machine: Machine<Input, Output>
    private let mapper: Mapper<Output, Direction<Input>>
    
    private var subscription: Subscription<Input>?
    
    internal init(_ machine: Machine<Input, Output>, function: @escaping Mapper<Output, Direction<Input>>) {
        self.machine = machine
        self.mapper = function
    }
    
    internal func process(input: Input?, callback: @escaping Handler<Output>) {
        if let input = input {
            subscription?.send(input: input)
        } else {
            subscription = ManualRoot(child: machine).start { [weak self] output in
                switch self?.mapper(output) {
                case .prop:
                    callback(output)
                case .back(let inputs):
                    inputs.forEach { [weak self] input in self?.subscription?.send(input: input) }
                case .none:
                    break
                }
            }
        }
    }
    
    
    private final class ManualRoot<Input, Output>: RootMachine {
        
        let child: Machine<Input, Output>
        
        init(child: Machine<Input, Output>) {
            self.child = child
        }
    }
}



public extension MachineType {
    
    
    func redirect(function: @escaping Mapper<Output, Direction<Input>>) -> Machine<Input, Output> {
        ~RedirectMachine(~self, function: function)
    }
}
