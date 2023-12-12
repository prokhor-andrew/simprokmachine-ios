//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//


public typealias Process<Input: Sendable> = (
    id: String,
    task: Task<Void, Never>,
    send: MachineCallback<Input>
)
