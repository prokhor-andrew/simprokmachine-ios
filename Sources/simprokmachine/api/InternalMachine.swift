//
//  InternalMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// Exists for implementation purposes
public struct InternalMachine<Input, Output> {
    
    internal let machine: Machine<Input, Output>
 
    internal init(_ machine: Machine<Input, Output>) {
        self.machine = machine
    }
}
