//
//  NSObject+Ext.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal extension NSObject {
    private struct AssociatedKeys {
        static var Bag = "MachineBag"
    }

    func doLocked(_ closure: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        closure()
    }

    var bag: Bag {
        get {
            var bag: Bag!
            doLocked {
                let lookup = objc_getAssociatedObject(self, &AssociatedKeys.Bag) as? Bag
                if let lookup = lookup {
                    bag = lookup
                } else {
                    let newBag = Bag()
                    self.bag = newBag
                    bag = newBag
                }
            }
            return bag
        } set {
            doLocked {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.Bag,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
