//
//  ParentSubscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class ParentSubscription<ParentInput, ChildInput>: BaseSubscription<ParentInput> {
   
    private let queue: DispatchQueue?
    private let mapper: Mapper<ParentInput, Ward<ChildInput>>
    
    private var composite: [BaseSubscription<ChildInput>] = []
    
    internal init<Output>(
        _ machine: Machine<ParentInput, Output>,
        queued: Bool,
        function: (
            @escaping Handler<ChildInput>
        ) -> [BaseSubscription<ChildInput>],
        mapper: @escaping Mapper<ParentInput, Ward<ChildInput>>
    ) {
        self.queue = queued ? DispatchQueue(Self.self, tag: "input") : nil
        self.mapper = mapper
        super.init(machine: machine)
        self.composite = function { [weak self] input in
            self?.composite.forEach { $0.set(input: input) }
        }
    }
    
    internal override func set(input: ParentInput) {
        let code = { [weak self] in
            guard let self = self else { return }
            self.mapper(input).values.forEach { val in
                self.composite.forEach { $0.set(input: val) }
            }
        }
        
        if let queue = queue {
            queue.async { code() }
        } else {
            code()
        }
    }
}
