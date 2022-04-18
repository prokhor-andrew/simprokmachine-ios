//
//  ConnectionType.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A type that represents a behavior of `ConnectableMachine`.
public enum ConnectionType<C: Connection> {
    
    /// Returning this value from `ConnectableMachine`'s `reducer` method ensures that `machines` specified in the object of `C: Connection` type will be connected and all of them will receive subscription event.
    case reduce(C)
    
    /// Returning this value from `ConnectableMachine`'s `reducer` method ensures that `machines` currently being connected will receive an input object of `(C: Connection).Input` type.
    case inward
}
