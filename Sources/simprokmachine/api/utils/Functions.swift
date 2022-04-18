//
//  Functions.swift
//  simprokmachine
//
//  Created by Andrey Prokhorenko on 28.11.2021.
//  Copyright (c) 2022 simprok. All rights reserved.

import Foundation


public typealias Handler<T> = (T) -> Void
public typealias BiHandler<T1, T2> = (T1, T2) -> Void
public typealias TriHandler<T1, T2, T3> = (T1, T2, T3) -> Void

public typealias Mapper<T, R> = (T) -> R
public typealias BiMapper<T1, T2, R> = (T1, T2) -> R
public typealias TriMapper<T1, T2, T3, R> = (T1, T2, T3) -> R

public typealias Supplier<T> = () -> T


