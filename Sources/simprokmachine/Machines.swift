//
//  Machines.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.


@resultBuilder
public struct MachinesBuilder<Input, Output> {
    private init() {
        
    }
    
    public static func buildBlock(_ components: Machines<Input, Output>...) -> [ParentMachine<Input, Output>] {
        components.flatMap { $0.array }
    }

    public static func buildBlock<M0: Automaton>(_ m0: M0) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output {
        [ParentMachine(m0)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton>(_ m0: M0, _ m1: M1) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output {
        [ParentMachine(m0), ParentMachine(m1)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton, M4: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3, _ m4: M4) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output, M4.Input == Input, M4.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3), ParentMachine(m4)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton, M4: Automaton, M5: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3, _ m4: M4, _ m5: M5) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output, M4.Input == Input, M4.Output == Output, M5.Input == Input, M5.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3), ParentMachine(m4), ParentMachine(m5)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton, M4: Automaton, M5: Automaton, M6: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3, _ m4: M4, _ m5: M5, _ m6: M6) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output, M4.Input == Input, M4.Output == Output, M5.Input == Input, M5.Output == Output, M6.Input == Input, M6.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3), ParentMachine(m4), ParentMachine(m5), ParentMachine(m6)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton, M4: Automaton, M5: Automaton, M6: Automaton, M7: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3, _ m4: M4, _ m5: M5, _ m6: M6, _ m7: M7) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output, M4.Input == Input, M4.Output == Output, M5.Input == Input, M5.Output == Output, M6.Input == Input, M6.Output == Output, M7.Input == Input, M7.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3), ParentMachine(m4), ParentMachine(m5), ParentMachine(m6), ParentMachine(m7)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton, M4: Automaton, M5: Automaton, M6: Automaton, M7: Automaton, M8: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3, _ m4: M4, _ m5: M5, _ m6: M6, _ m7: M7, _ m8: M8) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output, M4.Input == Input, M4.Output == Output, M5.Input == Input, M5.Output == Output, M6.Input == Input, M6.Output == Output, M7.Input == Input, M7.Output == Output, M8.Input == Input, M8.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3), ParentMachine(m4), ParentMachine(m5), ParentMachine(m6), ParentMachine(m7), ParentMachine(m8)]
    }
    
    public static func buildBlock<M0: Automaton, M1: Automaton, M2: Automaton, M3: Automaton, M4: Automaton, M5: Automaton, M6: Automaton, M7: Automaton, M8: Automaton, M9: Automaton>(_ m0: M0, _ m1: M1, _ m2: M2, _ m3: M3, _ m4: M4, _ m5: M5, _ m6: M6, _ m7: M7, _ m8: M8, _ m9: M9) -> [ParentMachine<Input, Output>] where M0.Input == Input, M0.Output == Output, M1.Input == Input, M1.Output == Output, M2.Input == Input, M2.Output == Output, M3.Input == Input, M3.Output == Output, M4.Input == Input, M4.Output == Output, M5.Input == Input, M5.Output == Output, M6.Input == Input, M6.Output == Output, M7.Input == Input, M7.Output == Output, M8.Input == Input, M8.Output == Output, M9.Input == Input, M9.Output == Output {
        [ParentMachine(m0), ParentMachine(m1), ParentMachine(m2), ParentMachine(m3), ParentMachine(m4), ParentMachine(m5), ParentMachine(m6), ParentMachine(m7), ParentMachine(m8), ParentMachine(m9)]
    }
}

public struct Machines<Input, Output> {
    
    public let array: [ParentMachine<Input, Output>]
    
    public init(@MachinesBuilder<Input, Output> _ build: Supplier<[ParentMachine<Input, Output>]>) {
        self.array = build()
    }
    
    public init(_ array: [ParentMachine<Input, Output>]) {
        self.array = array
    }

    public init() {
        self.init([])
    }
}
