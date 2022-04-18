//
//  BaseSubscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal class BaseSubscription<Input> {
        
    internal let machine: AnyObject?
    
    internal init(machine: AnyObject?) {
        self.machine = machine
    }
    
    internal func set(input: Input) {
        fatalError("not implemented")
    }
}
