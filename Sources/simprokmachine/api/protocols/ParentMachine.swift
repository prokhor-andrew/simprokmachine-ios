//
//  ParentMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 28.11.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


/// A protocol that describes an intermediate machine that passes input from its parent to the child, and its output from the child to the parent.
public protocol ParentMachine: MachineType {
    
    /// A child machine that receives input that comes from the parent machine, and emits output.
    var child: Machine<Input, Output> { get }
}

public extension ParentMachine {
    
    var `internal`: InternalMachine<Input, Output> {
        .init(.init(self) { machine, callback in
            [machine.child.subscribe(queued: false, callback: callback)]
        })
    }
}
