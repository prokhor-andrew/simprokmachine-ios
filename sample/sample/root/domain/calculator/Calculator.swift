//
//  Calculator.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine

final class Calculator: ChildMachine {
    typealias Input = CalculatorInput
    typealias Output = Int
    
    private var state: Int?
    
    var queue: MachineQueue { .main }
    
    func process(input: CalculatorInput?, callback: @escaping Handler<Output>) {
        if let input = input {
            switch input {
            case .incremenet:
                if let unwrapped = state {
                    state = unwrapped + 1
                }
            case .initialize(let value):
                state = value
            }
            if let state = state {
                callback(state)
            }
        }
    }
}
