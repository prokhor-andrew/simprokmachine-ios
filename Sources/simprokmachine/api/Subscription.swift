//
//  Subscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// Keep the instance of this object in order to keep the flow running
public struct Subscription {
    
    private let subscription: AnyObject
    
    internal init(_ subscription: AnyObject) {
        self.subscription = subscription
    }
}
