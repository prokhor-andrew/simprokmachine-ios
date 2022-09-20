//
//  Ward.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A type that represents a behavior of `MachineType.inward()` and `MachineType.outward()` operators.
public struct Ward<T> {

    /// Values that are sent either to the child or to the root depending on the used operator.
    public let values: [T]
    
    private init(_ values: [T]) {
        self.values = values
    }

    /// Creates a `Ward` object with specified `values` that are sent either to the child or to the root depending on the used operator.
    /// - parameter values - sent values.
    public static func set(_ values: T...) -> Ward<T> {
        .init(values)
    }
    
    /// Creates a `Ward` object with specified `values` that are sent either to the child or to the root depending on the used operator.
    /// - parameter values - sent values.
    public static func set(_ values: [T]) -> Ward<T> {
        .init(values)
    }
}
