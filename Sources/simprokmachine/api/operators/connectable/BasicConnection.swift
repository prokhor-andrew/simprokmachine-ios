//
//  BasicConnection.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// Basic implementation of `Connection` protocol
public struct BasicConnection<Input, Output>: Connection {
    
    /// `Connection` protocol property
    public let machines: [Machine<Input, Output>]
    
    /// - parameter machines - `Connection` protocol property
    public init(_ machines: [Machine<Input, Output>] = []) {
        self.machines = machines
    }
    
    /// - parameter machines - `Connection` protocol property
    public init(_ machines: Machine<Input, Output>...) {
        self.init(machines)
    }
    
    /// - parameter machine - a machine added to the `Connection` protocol property 
    public init<M: MachineType>(_ machine: M) where M.Input == Input, M.Output == Output {
        self.init([machine.machine])
    }
}
