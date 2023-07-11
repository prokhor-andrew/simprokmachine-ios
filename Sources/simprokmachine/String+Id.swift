//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 10.07.2023.
//


extension String {
    
    private final class Id {}
    
    static var id: String {
        "\(ObjectIdentifier(Id()))"
    }
}
