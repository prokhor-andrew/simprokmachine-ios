//
//  StorageReader.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import Foundation
import simprokmachine

final class StorageReader: ChildMachine {
    typealias Input = Void
    typealias Output = Int
    
    var queue: MachineQueue { .main }
    
    func process(input: Input?, callback: @escaping Handler<Output>) {
        callback(
            UserDefaults.standard.integer(forKey: calculator_storage_name)
        )
    }
}
