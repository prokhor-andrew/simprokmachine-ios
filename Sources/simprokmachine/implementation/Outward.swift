//
//  Outward.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal enum Outward<ChildInput, ParentOutput> {
    case setIn([ChildInput])
    case setOut([ParentOutput])
    case skip
    
    
    internal static func setOut(_ value: ParentOutput) -> Outward<ChildInput, ParentOutput> {
        .setOut([value])
    }
}
