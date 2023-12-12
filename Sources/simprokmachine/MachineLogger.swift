//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 12.12.2023.
//


public struct MachineLogger: Sendable {
    
    public static var `default`: MachineLogger {
        MachineLogger { _ in }
    }
    
    public let log: @Sendable (Loggable) -> Void
    
    public init(log: @escaping @Sendable (Loggable) -> Void) {
        self.log = log
    }
    
    public func callAsFunction(_ loggable: Loggable) {
        log(loggable)
    }
}
