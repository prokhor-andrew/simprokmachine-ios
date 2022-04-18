//
//  UIWindow+Machine.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine
import UIKit

extension UIWindow: ParentMachine {
    public typealias Input = String
    public typealias Output = Void
    
    public var child: Machine<Input, Output> {
        if let rootVC = rootViewController as? MainViewController {
            return rootVC.machine
        } else {
            fatalError("unexpected behavior") // we can return an empty machine here but for the example let's crash it
        }
    }
}
