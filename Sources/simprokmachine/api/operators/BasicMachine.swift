//
//  BasicMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A class that describes a machine with an injectable processing behavior.
public final class BasicMachine<Input, Output>: ChildMachine {

    private let processor: BiHandler<Input?, Handler<Output>>
    
    /// - parameter queue: `ChildMachine` queue protocol property
    /// - parameter processor: triggered when `process()` method is triggered.
    public init(queue: MachineQueue = .new, processor: @escaping BiHandler<Input?, Handler<Output>>) {
        self.processor = processor
        self.queue = queue
    }
    
    /// `ChildMachine` protocol property
    public let queue: MachineQueue
    
    /// `ChildMachine` protocol method
    public func process(input: Input?, callback: @escaping Handler<Output>) {
        processor(input, callback)
    }
}
