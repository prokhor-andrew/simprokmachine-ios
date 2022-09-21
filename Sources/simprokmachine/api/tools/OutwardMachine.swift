//
//  OutwardMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

internal final class OutwardMachine<ParentOutput, ChildOutput, Input> : ChildMachine {
    internal typealias Input = Input
    internal typealias Output = ParentOutput
    
    internal var queue: MachineQueue { .new }
    
    private let machine: Machine<Input, ChildOutput>
    private let mapper: Mapper<ChildOutput, Ward<ParentOutput>>
    
    private var subscription: Subscription<Input>?
    
    internal init(_ machine: Machine<Input, ChildOutput>, function: @escaping Mapper<ChildOutput, Ward<ParentOutput>>) {
        self.machine = machine
        self.mapper = function
    }
    
    internal func process(input: Input?, callback: @escaping Handler<ParentOutput>) {
        if let input = input {
            subscription?.send(input: input)
        } else {
            subscription = ManualRoot(child: machine).start { [weak self] output in
                self?.mapper(output).values.forEach(callback)
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
    
    func outward<ParentOutput>(function: @escaping Mapper<Output, Ward<ParentOutput>>) -> Machine<Input, ParentOutput> {
        ~OutwardMachine(~self, function: function)
    }
}
