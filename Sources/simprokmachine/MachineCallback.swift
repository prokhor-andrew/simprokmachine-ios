//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 15.11.2023.
//



public struct MachineCallback<T: Sendable>: Sendable {
    
    public let function: @Sendable (T) async -> Bool
    
    internal init(_ function: @escaping @Sendable (T) async -> Bool) {
        self.function = function
    }
    
    @discardableResult
    public func callAsFunction(_ value: T) async -> Bool {
        await function(value)
    }
}
