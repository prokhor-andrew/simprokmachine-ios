//
//  EmitterMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class EmitterMachine<Input, Output>: ChildMachine {
    typealias Input = EmitterInput<Input>
    typealias Output = EmitterOutput<Input, Output>
    
    private var callback: Handler<EmitterOutput<Input, Output>>?
    
    var queue: MachineQueue { .new }
    
    func send(_ val: Input) {
        callback?(.toConnected(val))
    }
    
    func process(input: EmitterInput<Input>?, callback: @escaping Handler<EmitterOutput<Input, Output>>) {
        self.callback = callback
    }
}
