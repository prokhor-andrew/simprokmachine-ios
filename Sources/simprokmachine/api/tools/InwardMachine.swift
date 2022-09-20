//
//  InwardMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.


internal final class InwardMachine<ParentInput, ChildInput, Output> : ChildMachine {
    internal typealias Input = ParentInput
    internal typealias Output = Output
    
    internal var queue: MachineQueue { .new }
    
    private let machine: Machine<ChildInput, Output>
    private let mapper: Mapper<ParentInput, Ward<ChildInput>>
    
    private var subscription: Subscription<ChildInput>?
    
    internal init(_ machine: Machine<ChildInput, Output>, function: @escaping Mapper<ParentInput, Ward<ChildInput>>) {
        self.machine = machine
        self.mapper = function
    }
    
    internal func process(input: ParentInput?, callback: @escaping Handler<Output>) {
        if let input = input {
            mapper(input).values.forEach {
                subscription?.send(input: $0)
            }
        } else {
            subscription = ManualRoot(child: machine).start(callback: callback)
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
    
    func inward2<ParentInput>(function: @escaping Mapper<ParentInput, Ward<Input>>) -> Machine<ParentInput, Output> {
        ~InwardMachine(~self, function: function)
    }
}
