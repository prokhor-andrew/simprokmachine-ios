//
//  ParentSubscription.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class ParentSubscription<Input>: BaseSubscription<Input> {
   
    private let queue: DispatchQueue?
    
    private var sub: BaseSubscription<Input>?
    
    internal init<Output>(
        _ machine: Machine<Input, Output>,
        queued: Bool,
        function: (@escaping Handler<Input>) -> BaseSubscription<Input>?
    ) {
        self.queue = queued ? DispatchQueue(Self.self, tag: "input") : nil
        super.init(machine: machine)
        self.sub = function { [weak self] input in
            self?.sub?.set(input: input)
        }
    }
    
    internal override func set(input: Input) {
        let code = { [weak self] in
            guard let self = self else { return }
            self.sub?.set(input: input)
        }
        
        if let queue = queue {
            queue.async { code() }
        } else {
            code()
        }
    }
}
