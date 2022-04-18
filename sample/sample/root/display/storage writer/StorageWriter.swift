//
//  StorageWriter.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine
import Foundation

final class StorageWriter<Output>: ChildMachine {
    typealias Input = Int
    
    var queue: MachineQueue { .main }
    
    func process(input: Int?, callback: @escaping Handler<Output>) {
        if let input = input {
            UserDefaults.standard.set(input, forKey: calculator_storage_name)
        }
    }
}
