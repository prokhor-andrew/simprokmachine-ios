//
//  Operators.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


public extension MachineType {
    
    /// Creates a `Machine` instance with a specific behavior applied.
    /// Every input of the resulting machine is mapped into an array of new inputs and passed to the child.
    /// - parameter mapper: a mapper that receives triggering input and returns `Ward` object with new array of inputs as `values`.
    func inward<RInput>(
        _ mapper: @escaping Mapper<RInput, Ward<Input>>
    ) -> Machine<RInput, Output> {
        ~MapMachine(self, in: mapper)
    }
        
    /// Creates a `Machine` instance with a specific behavior applied.
    /// Every output of the child machine is mapped into an array of new outputs and passed to the root.
    /// - parameter mapper: a mapper that receives triggering output and returns `Ward` object with new array of outputs as `values`.
    func outward<ROutput>(
        _ mapper: @escaping Mapper<Output, Ward<ROutput>>
    ) -> Machine<Input, ROutput> {
        ~MapMachine(self , out: { .setOut(mapper($0).values) })
    }
    
    /// Creates a `Machine` instance with a specific behavior applied.
    /// Every output of the child machine is either passed further to the root or mapped into an array of new inputs and passed back to the child depending on the `Direction` value returned from `mapper`
    /// - parameter mapper: a mapper that receives triggering output and returns `Direction` object.
    /// If `Direction.prop` returned - output is pushed further to the root.
    /// If `Direction.back([Input])` returned - an array of new inputs is passed back to the child.
    func redirect(
        _ mapper: @escaping Mapper<Output, Direction<Input>>
    ) -> Machine<Input, Output> {
        ~MapMachine(self, out: {
            switch mapper($0) {
            case .prop:
                return .setOut($0)
            case .back(let values):
                return .setIn(values)
            }
        })
    }
}


public extension MachineType {
    
    /// Creates a `Machine` instance with a specific behavior applied.
    /// Every input of the resulting machine is passed into every child from the `machines` array as well as every output of every child is passed into the resulting machine.
    /// - parameter machines: array of machines that are merged.
    static func merge(_ machines: [Machine<Input, Output>]) -> Machine<Input, Output> {
        ~(~MergeMachine(machines))
    }

    
    /// Creates a `Machine` instance with a specific behavior applied.
    /// Every input of the resulting machine is passed into every child from the `machines` array as well as every output of every child is passed into the resulting machine.
    /// - parameter machines: array of machines that are merged.
    static func merge(_ machines: Machine<Input, Output>...) -> Machine<Input, Output> {
        ~(~MergeMachine(machines))
    }
}

/// A different API for `MachineType.merge()` static method.
public func merge<Input, Output>(_ machines: [Machine<Input, Output>]) -> Machine<Input, Output> {
    .merge(machines)
}

/// A different API for `MachineType.merge()` static method.
public func merge<Input, Output>(_ machines: Machine<Input, Output>...) -> Machine<Input, Output> {
    .merge(machines)
}
