//
//  Machine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A general class that describes a type that represents a machine object.
public final class Machine<Input, Output> {
    
    private let machineType: AnyObject
    private let subscrubeFunc: (
        Machine<Input, Output>,
        Bool,
        @escaping Handler<Output>
    ) -> BaseSubscription<Input>
 
    private init(
        machineType: AnyObject,
        subscrubeFunc: @escaping (
            Machine<Input, Output>,
            Bool,
            @escaping Handler<Output>
        ) -> BaseSubscription<Input>
    ) {
        self.machineType = machineType
        self.subscrubeFunc = subscrubeFunc
    }
    
    internal convenience init<M: MachineType>(
        _ machineType: M,
        inMapper: @escaping Mapper<Input, Ward<M.Input>>,
        outMapper: @escaping Mapper<M.Output, Outward<M.Input, Output>>,
        subscribeFunc: @escaping (M, @escaping Handler<M.Output>) -> [BaseSubscription<M.Input>]
    ) {
        self.init(machineType: machineType) { [weak machineType] machine, queued, callback in
            guard let machineType = machineType else { return EmptySubscription() }
            return ParentSubscription(
                machine,
                queued: queued,
                function: { [weak machineType] setter in
                    guard let machineType = machineType else { return [] }
                    
                    return subscribeFunc(machineType) { output in
                        switch outMapper(output) {
                        case .skip:
                            break // do nothing
                        case .setIn(let inputs):
                            inputs.forEach { setter($0) }
                        case .setOut(let mappedOutputs):
                            mappedOutputs.forEach { callback($0) }
                        }
                    }
                },
                mapper: inMapper
            )
        }
    }
    
    internal func subscribe(
        queued: Bool,
        callback: @escaping Handler<Output>
    ) -> BaseSubscription<Input> {
        subscrubeFunc(self, queued, callback)
    }
}

extension Machine: MachineType {
    
    /// Wrapper used for implementation purposes
    public var `internal`: InternalMachine<Input, Output> { .init(self) }
}

/// API
public extension Machine {
    /// - parameter machineType: a function that returns a `MachineType` object used for creating an instance.
    convenience init<M: MachineType>(_ machineType: Supplier<M>) where M.Input == Input, M.Output == Output {
        self.init(machineType())
    }
    
    /// - parameter machineType: a `MachineType` object used for creating an instance.
    convenience init<M: MachineType>(_ machineType: M) where M.Input == Input, M.Output == Output {
        let copied = machineType.machine
        self.init(machineType: copied.machineType, subscrubeFunc: copied.subscrubeFunc)
    }
    
    /// This is equivalent to Machine(self)
    var machine: Machine<Input, Output> { `internal`.machine }
    
    /// This is equivalent to Machine(self)
    prefix static func ~(operand: Machine<Input, Output>) -> Machine<Input, Output> {
        operand.machine
    }
}


public extension MachineType {
    
    /// This is equivalent to Machine(self)
    var machine: Machine<Input, Output> { `internal`.machine }
    
    /// This is equivalent to Machine(self)
    prefix static func ~(operand: Self) -> Machine<Input, Output> {
        operand.machine
    }
}
