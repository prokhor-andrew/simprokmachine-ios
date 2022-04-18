//
//  Domain.swift
//  sample
//
//  Created by Andrey Prokhorenko on 19.02.2022.
//

import simprokmachine


final class Domain: ParentMachine {
    typealias Input = AppEvent
    typealias Output = AppEvent
    
    var child: Machine<AppEvent, AppEvent> {
        func calculator(_ initial: Int) -> Machine<DomainInput, DomainOutput> {
            Calculator(initial: initial).outward {
                .set(.fromCalculator($0))
            }.inward {
                switch $0 {
                case .fromParent:
                    return .set(Void())
                case .fromReader:
                    return .set()
                }
            }
        }
        
        let reader: Machine<DomainInput, DomainOutput> = StorageReader().outward { .set(.fromReader($0)) }.inward { _ in .set() }
        
        let connectable: Machine<DomainInput, DomainOutput> = ConnectableMachine(BasicConnection(reader)) { state, input in
            switch input {
            case .fromReader(let val):
                return .reduce(BasicConnection(calculator(val)))
            case .fromParent:
                return .inward
            }
        }.redirect { output in
            switch output {
            case .fromReader(let val):
                return .back(.fromReader(val))
            case .fromCalculator:
                return .prop
            }
        }
        
        return connectable.outward { output in
            switch output {
            case .fromReader:
                return .set()
            case .fromCalculator(let val):
                return .set(.didChangeState(val))
            }
        }.inward {
            switch $0 {
            case .didChangeState:
                return .set()
            case .willChangeState:
                return .set(.fromParent)
            }
        }
    }
}
