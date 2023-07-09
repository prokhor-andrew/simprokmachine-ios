//
//  File 2.swift
//  
//
//  Created by Andriy Prokhorenko on 02.07.2023.
//


final class ChannelIterator<T>: Sendable, AsyncIteratorProtocol {
    typealias Element = T
    
    private let state: ManagedCriticalState<ChannelState>
    
    init() {
        fatalError()
    }
    
    func next() async -> T? {
        fatalError()
    }
    
    func yield(_ val: T) {
        
    }
}

final class Channel<T>: Sendable, AsyncSequence {
    typealias AsyncIterator = ChannelIterator<T>
    typealias Element = T
    
    private let iterator = ChannelIterator<T>()
    
    func makeAsyncIterator() -> ChannelIterator<T> { iterator }
    
    @Sendable
    func yield(_ val: T) async {
        iterator.yield(val)
    }
}


struct ChannelState {
    
}
