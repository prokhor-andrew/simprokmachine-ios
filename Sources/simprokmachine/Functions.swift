//
//  File.swift
//  
//
//  Created by Andriy Prokhorenko on 08.07.2023.
//


public typealias Action = () -> Void
public typealias Handler<T> = (T) -> Void
public typealias BiHandler<T1, T2> = (T1, T2) -> Void
public typealias TriHandler<T1, T2, T3> = (T1, T2, T3) -> Void

public typealias Mapper<T, R> = (T) -> R
public typealias BiMapper<T1, T2, R> = (T1, T2) -> R
public typealias TriMapper<T1, T2, T3, R> = (T1, T2, T3) -> R

public typealias Supplier<T> = () -> T


public typealias AsyncAction = () async -> Void
public typealias AsyncHandler<T> = (T) async -> Void
public typealias AsyncBiHandler<T1, T2> = (T1, T2) async -> Void
public typealias AsyncTriHandler<T1, T2, T3> = (T1, T2, T3) async -> Void

public typealias AsyncMapper<T, R> = (T) async -> R
public typealias AsyncBiMapper<T1, T2, R> = (T1, T2) async -> R
public typealias AsyncTriMapper<T1, T2, T3, R> = (T1, T2, T3) async -> R

public typealias AsyncSupplier<T> = () async -> T
