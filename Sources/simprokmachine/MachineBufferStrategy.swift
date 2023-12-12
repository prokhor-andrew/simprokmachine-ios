//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 15.11.2023.
//

public struct MachineBufferStrategy<T: Sendable>: Sendable {
    
    public static var `default`: MachineBufferStrategy<T> {
        MachineBufferStrategy { state, _, _, _ in state }
    }
    
    public let bufferReducer: @Sendable ([MachineBufferData<T>], MachineBufferEvent, MachineLogger, String) -> [MachineBufferData<T>]
    
    public init(bufferReducer: @escaping @Sendable ([MachineBufferData<T>], MachineBufferEvent, MachineLogger, String) -> [MachineBufferData<T>]) {
        self.bufferReducer = bufferReducer
    }
}
