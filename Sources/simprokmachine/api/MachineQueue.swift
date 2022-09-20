//
//  MachineQueue.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A type used in `ChildMachine` as a protocol property, and represents a behavior of `ChildMachine.process()` method.
public enum MachineQueue {
    
    /// Returning this value from `ChildMachine`'s queue property ensures that `ChildMachine`'s `process()` runs on `DispatchQueue.main` asynchronously.
    case main
    
    /// Returning this value from `ChildMachine`'s queue property ensures that `ChildMachine`'s `process()` runs on a serial `DispatchQueue` asynchronously with `DispatchQoS.userInteractive` setting.
    case new
}
