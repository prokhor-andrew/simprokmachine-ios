//
//  Array+Copy.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal extension Array {
    
    func copy(add element: Element) -> Array<Element> {
        var copied = self
        copied.append(element)
        return copied
    }
}

internal extension Array where Element: AnyObject {
    
    func removeDuplicates() -> Array<Element> {
        reduce([]) { cur, element in
            if cur.contains(where: { $0 === element }) {
                return cur
            } else {
                return cur.copy(add: element)
            }
        }
    }
}
