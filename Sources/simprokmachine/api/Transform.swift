//
//  Transform.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.


public enum Transition<F: Scenario> {
    case skip
    case set(F)
}

public enum Directed<Internal, External> {
    case int(Internal)
    case ext(External)
}

public protocol Scenario {
    associatedtype InternalInput
    associatedtype InternalOutput
    associatedtype ExternalInput
    associatedtype ExternalOutput
    
    associatedtype ToScenario: Scenario where
        ToScenario.InternalInput == InternalInput,
        ToScenario.InternalOutput == InternalOutput,
        ToScenario.ExternalInput == ExternalInput,
        ToScenario.ExternalOutput == ExternalOutput
        
    var outputs: [Directed<InternalOutput, ExternalOutput>] { get }
    
    var machines: [Machine<InternalOutput, InternalInput>] { get }
    
    func transit(with input: Directed<InternalInput, ExternalInput>) -> Transition<ToScenario>
}


public extension Machine {
    typealias ExternalInput = Input
    typealias ExternalOutput = Output
    
    convenience init<S: Scenario>(_ scenario: S) where S.ExternalInput == ExternalInput, S.ExternalOutput == ExternalOutput {
        self.init(TransformerMachine(scenario))
    }
}

private struct BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput>: Scenario {
    typealias ToScenario = BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput>
    
    let outputs: [Directed<InternalOutput, ExternalOutput>]
    let machines: [Machine<InternalOutput, InternalInput>]
    
    private let _transit: (Directed<InternalInput, ExternalInput>) -> Transition<BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput>>
    
    init(
        outputs: [Directed<InternalOutput, ExternalOutput>],
        machines: [Machine<InternalOutput, InternalInput>],
        transit: @escaping (Directed<InternalInput, ExternalInput>) -> Transition<BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput>>
    ) {
        self.outputs = outputs
        self.machines = machines
        self._transit = transit
    }
    
    func transit(with input: Directed<InternalInput, ExternalInput>) -> Transition<BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput>> {
        _transit(input)
    }
}

private extension Scenario {
    
    var basic: BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput> {
        BasicScenario(outputs: outputs, machines: machines) {
            switch transit(with: $0) {
            case .skip:
                return .skip
            case .set(let new):
                return .set(new.basic)
            }
        }
    }
}

private final class TransformerMachine<InternalInput, InternalOutput, ExternalInput, ExternalOutput>: ChildMachine {
    typealias Input = ExternalInput
    typealias Output = ExternalOutput
    
    private var state: BasicScenario<InternalInput, InternalOutput, ExternalInput, ExternalOutput>
    
    private var subscriptions: [ObjectIdentifier: Subscription<InternalOutput>] = [:]
                                                                                                
    init<S: Scenario>(_ initial: S) where S.InternalInput == InternalInput, S.InternalOutput == InternalOutput, S.ExternalInput == ExternalInput, S.ExternalOutput == ExternalOutput {
        self.state = initial.basic
    }
    
    var queue: MachineQueue { .new }
    
    func process(input: Input?, callback: @escaping Handler<Output>) {
        if let input = input {
            handle(event: .ext(input), callback: callback)
        } else {
            // initial
            config(callback: callback)
        }
    }
    
    private func handle(event: Directed<InternalInput, ExternalInput>, callback: @escaping Handler<Output>) {
        switch state.transit(with: event) {
        case .skip:
            break
        case .set(let new):
            state = new
            config(callback: callback)
        }
    }
    
    private func config(callback: @escaping Handler<Output>) {
        // removing subscriptions that are not present in new state
        subscriptions = subscriptions.reduce(subscriptions) { dict, element in
            let (key, _) = element
            
            let ids: Set<ObjectIdentifier> = Set(state.machines.map { ObjectIdentifier($0) })
            if !ids.contains(key) {
                var copy = dict
                copy.removeValue(forKey: key)
                return copy
            } else {
                return dict
            }
        }
        
        // adding subscriptions that are present in new state
        subscriptions = state.machines.reduce(subscriptions) { [weak self] dict, machine in
            let key = ObjectIdentifier(machine)
            
            if dict[key] == nil {
                var copy = dict
                copy[key] = ManualRoot(machine).start { [weak self] output in
                    self?.handle(event: .int(output), callback: callback)
                }
                return copy
            } else {
                return dict
            }
        }
        
        // sending outputs
        state.outputs.forEach { event in
            switch event {
            case .int(let output):
                subscriptions.forEach { $0.value.send(input: output) }
            case .ext(let output):
                callback(output)
            }
        }
    }
}


private final class ManualRoot<Input, Output>: RootMachine {
    
    let child: Machine<Input, Output>
    
    init(_ child: Machine<Input, Output>) {
        self.child = child
    }
}
