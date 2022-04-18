//
//  WeakMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A class that describes a machine with an injectable processinging behavior over the weakly referenced injected object.
public final class WeakMachine<Input, Output>: ChildMachine {
    
    private let processor: BiHandler<Input?, Handler<Output>>
    
    /// - parameter object: weakly referenced object that is passed into the injected `processor()` function.
    /// - parameter processor: triggered when `process()` method is triggered with a weakly referenced injected `object` passed in as the first parameter.
    public init<O: AnyObject>(
        _ object: O,
        processor: @escaping TriHandler<O, Input?, Handler<Output>>
    ) {
        weak var weakObject = object
        self.processor = { input, callback in
            guard let object = weakObject else { return }
            processor(object, input, callback)
        }
    }
    
    /// `ChildMachine` protocol property
    public var queue: MachineQueue { .main }
    
    /// `ChildMachine` protocol method
    public func process(input: Input?, callback: @escaping Handler<Output>) {
        processor(input, callback)
    }
}
