//
//  MachineType.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 28.11.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A general protocol that describes a type that represents a machine object. Exists for implementation purposes, and must not be conformed to directly.
public protocol MachineType: AnyObject {
    associatedtype Input
    associatedtype Output
    
    var `internal`: InternalMachine<Input, Output> { get }
}
