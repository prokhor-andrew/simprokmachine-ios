//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 15.11.2023.
//


public enum MachineBufferEvent: Sendable {
    case added
    case removed(isConsumed: Bool)
    
    public var isAdded: Bool {
        switch self {
        case .added: true
        case .removed: false
        }
    }
    
    public var isRemoved: Bool {
        switch self {
        case .removed: true
        case .added: false
        }
    }
    
    public var isCancelled: Bool? {
        switch self {
        case .added: nil
        case .removed(let isConsumed): !isConsumed
        }
    }
    
    public var isConsumed: Bool? {
        switch self {
        case .added: nil
        case .removed(let isConsumed): isConsumed
        }
    }
}
