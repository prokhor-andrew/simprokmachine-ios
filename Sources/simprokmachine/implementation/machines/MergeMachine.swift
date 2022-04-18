//
//  MergeMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class MergeMachine<Input, Output>: MachineType {
    public typealias Input = Input
    public typealias Output = Output
  
    private let machines: [Machine<Input, Output>]
    
    internal init(_ machines: [Machine<Input, Output>]) {
        self.machines = machines.removeDuplicates()
    }
    
    internal var `internal`: InternalMachine<Input, Output> {
        .init(.init(self, inMapper: { .set($0) }, outMapper: { .setOut($0) }) { machine, callback in
            machine.machines.map { $0.subscribe(queued: true, callback: callback) }
        })
    }
}
