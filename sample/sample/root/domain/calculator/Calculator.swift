//
//  Calculator.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine

final class Calculator: ChildMachine {
    typealias Input = Void
    typealias Output = Int
    
    private var state: Int
    
    init(initial: Int) {
        state = initial
    }
    
    var queue: MachineQueue { .main }
    
    func process(input: Input?, callback: @escaping Handler<Output>) {
        if input != nil {
            state += 1
        }
        callback(state)
    }
}
