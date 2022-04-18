//
//  EmptySubscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class EmptySubscription<Input>: BaseSubscription<Input> {
    
    internal init() {
        super.init(machine: nil)
    }
    
    internal override func set(input: Input) {
        // do nothing
    }
}
