//
//  Automaton.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 28.11.2021.
//  Copyright (c) 2022 simprok. All rights reserved.



public protocol Automaton: AnyObject {
    associatedtype Input
    associatedtype Output
    
    var isProcessOnMain: Bool { get }
    
    func onProcess(input: Input?, callback: @escaping Handler<Output>)
    
    func onClearUp()
}

public extension Automaton {
    
    func subscribe(_ function: @escaping BiHandler<Output, Handler<Input>>) -> Subscription<Input, Output> {
        Subscription(machine: self, callback: function)
    }
}

