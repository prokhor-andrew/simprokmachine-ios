//
//  Direction.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A type that represents a behavior of `MachineType.redirect()` operator.
public enum Direction<Input> {
    
    /// Returning this value from `MachineType.redirect()` method ensures that the output will be pushed further to the root.
    case prop
    
    /// Returning this value from `MachineType.redirect()` method ensures that `[Input]` will be sent back to the child.
    case back([Input])
    
    /// Creates a `Direction.back` object with `values` as `[Input]`.
    public static func back(_ values: Input...) -> Direction<Input> {
        .back(values)
    }
}
