//
//  Bag.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class Bag {
    private var sub: Subscription?
    
    deinit {
        clear()
    }
    
    internal func clear() {
        sub = nil
    }
    
    internal func save(_ sub: Subscription) {
        self.sub = sub
    }
}
