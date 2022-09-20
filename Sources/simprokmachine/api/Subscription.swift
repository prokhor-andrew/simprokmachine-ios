//
//  Subscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// Keep the instance of this object in order to keep the flow running
public struct Subscription<Input> {
    
    private let subscription: BaseSubscription<Input>
    
    internal init(_ subscription: BaseSubscription<Input>) {
        self.subscription = subscription
    }
    
    
    public func send(input: Input) {
        subscription.set(input: input)
    }
}
