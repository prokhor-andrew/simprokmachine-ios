//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 22.11.2023.
//


public struct MachineBufferData<T: Sendable>: Identifiable, Sendable {
    
    public let id: String
    public let data: T
    
    internal let cont: CheckedContinuation<Bool, Never>
    
    internal init(id: String, data: T, cont: CheckedContinuation<Bool, Never>) {
        self.id = id
        self.data = data
        self.cont = cont
    }
}


extension MachineBufferData: Equatable {
    public static func == (lhs: MachineBufferData<T>, rhs: MachineBufferData<T>) -> Bool {
        lhs.id == rhs.id
    }
}

extension MachineBufferData: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
