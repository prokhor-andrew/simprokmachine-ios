//
//  Display.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine
import UIKit


final class Display: ParentMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent
    
    
    var child: Machine<AppEvent, AppEvent> {
        let window = UIApplication.shared.delegate!.window!!
            
        return Machine.merge(
            StorageWriter().inward { input in
                switch input {
                case .willChangeState:
                    return .set()
                case .didChangeState(let val):
                    return .set(val)
                }
            },
            
            Machine.merge(
                ~Logger(),
                window.outward { .set(.willChangeState) }
            ).inward { input in
                switch input {
                case .didChangeState(let val):
                    return .set("\(val)")
                case .willChangeState:
                    return .set()
                }
            }
        )
    }
}
