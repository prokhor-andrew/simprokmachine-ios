//
//  ParentAutomaton.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.


public protocol ParentAutomaton: Automaton {
    associatedtype Child: Automaton where Child.Input == Input, Child.Output == Output
    
    
    var child: Child { get }
}

public extension ParentAutomaton {
    
    var isProcessOnMain: Bool { false }
    
    func onProcess(input: Input?, callback: @escaping Handler<Output>) {
        if let input = input {
            (adopted[ObjectIdentifier(self)] as? Subscription<Input, Output>)?.send(input: input)
        } else {
            adopted[ObjectIdentifier(self)] = child.subscribe { output, _ in callback(output) }
        }
    }
    
    func onClearUp() {
        adopted.removeValue(forKey: ObjectIdentifier(self))
    }
}

fileprivate var adopted: [ObjectIdentifier: AnyObject] = [:]
