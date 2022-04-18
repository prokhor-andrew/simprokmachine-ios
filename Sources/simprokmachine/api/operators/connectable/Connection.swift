//
//  Connection.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// An object that represents state in `ConnectableMachine`'s reducer
public protocol Connection {
    associatedtype Input
    associatedtype Output
    
    /// Machines that are connected in `ConnectableMachine`.
    var machines: [Machine<Input, Output>] { get }
}
