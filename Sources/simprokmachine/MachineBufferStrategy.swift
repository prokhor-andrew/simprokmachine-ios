//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//


public struct MachineBufferStrategy<Event>: Sendable {
    
    public let name: String
    public let reducer: @Sendable ([Event], Event) -> [Event]
    
    private init(_ name: String, _ reducer: @Sendable @escaping ([Event], Event) -> [Event]) {
        self.name = name
        self.reducer = reducer
    }
    
    public static func custom(
        name: String,
        reducer: @Sendable @escaping ([Event], Event) -> [Event]
    ) -> MachineBufferStrategy<Event> {
        self.init(name, reducer)
    }
}


extension MachineBufferStrategy: Equatable {
    public static func == (lhs: MachineBufferStrategy<Event>, rhs: MachineBufferStrategy<Event>) -> Bool {
        lhs.name == rhs.name
    }
}

extension MachineBufferStrategy: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
