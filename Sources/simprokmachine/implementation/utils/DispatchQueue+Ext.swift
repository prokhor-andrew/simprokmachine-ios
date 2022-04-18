//
//  DispatchQueue+Ext.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal extension DispatchQueue {
    
    convenience init<T>(_ type: T.Type, tag: String) {
        self.init(label: String(describing: T.self) + "/" + tag, qos: .userInteractive)
    }
}
