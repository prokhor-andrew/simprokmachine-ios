//
//  MapMachine.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 01.12.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


internal final class MapMachine<Input, Output>: MachineType {
    public typealias Input = Input
    public typealias Output = Output

    internal convenience init<M: MachineType>(
        _ machine: M,
        out outMapper: @escaping Mapper<M.Output, Outward<M.Input, Output>>
    ) where M.Input == Input {
        self.init(machine, in: { .set($0) }, out: outMapper)
    }

    internal convenience init<M: MachineType>(
        _ machine: M,
        in inMapper: @escaping Mapper<Input, Ward<M.Input>>
    ) where M.Output == Output {
        self.init(machine, in: inMapper, out: { .setOut($0) })
    }
    
    private let function: Mapper<MapMachine<Input, Output>, Machine<Input, Output>>
    
    private init<M: MachineType>(
        _ machineType: M,
        in inMapper: @escaping Mapper<Input, Ward<M.Input>>,
        out outMapper: @escaping Mapper<M.Output, Outward<M.Input, Output>>
    ) {
        function = { mapMachine in
            .init(
                mapMachine,
                inMapper: { .set($0) },
                outMapper: { .setOut($0) }
            ) { [weak machineType] _, callback in
                if let machineType = machineType {
                    return [
                        Machine(
                            machineType,
                            inMapper: inMapper,
                            outMapper: { outMapper($0) }
                        ) { machineType, callback in
                            [machineType.machine.subscribe(queued: true, callback: callback)]
                        }
                        .subscribe(queued: false, callback: callback)
                    ]
                } else {
                    return []
                }
            }
        }
    }
    
    internal var `internal`: InternalMachine<Input, Output> { .init(function(self)) }
}

