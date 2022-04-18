//
//  Logger.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine

final class Logger<Output>: ChildMachine {
    typealias Input = String
    
    let queue: MachineQueue = .main
    
    func process(input: String?, callback: @escaping Handler<Output>) {
        print("\(input ?? "loading")")
    }
}
