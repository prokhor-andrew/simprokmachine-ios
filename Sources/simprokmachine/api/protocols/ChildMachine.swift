//
//  ChildMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 28.11.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A protocol that describes a machine with a customizable handling of input, and emitting of output.
public protocol ChildMachine: MachineType {
    
    /// A property that describes a `DispatchQueue` which the `process()` method runs on.
    var queue: MachineQueue { get }
    
    /// Triggered after the subscription to the machine and every time input is received.
    /// - parameter input: a received input. `nil` if triggered after subscription.
    /// - parameter callback: a callback used for emitting output.
    func process(input: Input?, callback: @escaping Handler<Output>)
}

public extension ChildMachine {
    
    var `internal`: InternalMachine<Input, Output> {
        .init(.init(
            self,
            inMapper: { .set($0) },
            outMapper: { .setOut($0) }
        ) { machine, callback in
            [ChildSubscription(machine, callback)]
        })
    }
}
