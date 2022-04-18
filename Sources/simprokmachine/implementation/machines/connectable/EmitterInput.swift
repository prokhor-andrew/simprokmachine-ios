//
//  EmitterInput.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal struct EmitterInput<T> {
    
    internal let value: T
    
    internal init(_ value: T) {
        self.value = value
    }
}
