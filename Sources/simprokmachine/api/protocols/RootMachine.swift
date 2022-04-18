//
//  RootMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A protocol that describes the top-level machine of the application with all its children, and manages the start/stop functions of the data flow.
public protocol RootMachine {
    associatedtype Input
    associatedtype Output
    
    /// Top level machine
    var child: Machine<Input, Output> { get }
}

public extension RootMachine {
    
    /// Subscribes `child` machine specified in `RootMachine` and its sub-machines.
    /// - parameter callback - receives machine's output. Not recommended to be used. Exists for edge-cases. Prefer using child machine that receives input and handles it.
    func start(callback: @escaping Handler<Output> = { _ in }) -> Subscription {
        Subscription(child.subscribe(queued: true, callback: callback))
    }
}


public extension RootMachine where Self: NSObject {
    
    /// Triggers `RootMachine start()` method and saves its `Subscription`.
    func start(callback: @escaping Handler<Output> = { _ in }) {
        bag.save(start(callback: callback))
    }
    
    /// Removes saved `Subscription`.
    func stop() {
        bag.clear()
    }
}
