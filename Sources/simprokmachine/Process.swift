//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 25.06.2023.
//

public struct Process<Input: Sendable>: Sendable, Identifiable, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: String
    private let _send: MachineCallback<Input>
    private let _cancel: @Sendable () -> Void
    
    internal init(id: String, cancel _cancel: @escaping @Sendable () -> Void, send _send: MachineCallback<Input>) {
        self.id = id
        self._cancel = _cancel
        self._send = _send
    }
    
    public func cancel() {
        _cancel()
    }
    
    @discardableResult
    public func send(_ input: Input) async -> Bool {
        await _send(input)
    }
    
    public var description: String {
        "Process<\(Input.self)> id=\(id)"
    }
    
    public var debugDescription: String { description }
    
    public static func == (lhs: Process<Input>, rhs: Process<Input>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
