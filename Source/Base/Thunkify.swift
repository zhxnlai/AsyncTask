//
//  Thunkify.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

public func thunkify<A, T>(function: (A, T -> Void) -> Void) -> (A -> Task<T>) {
    return {a in Task<T> {callback in function(a, callback) } }
}

public func thunkify<A, B, T>(function: (A, B, T -> Void) -> Void) -> ((A, B) -> Task<T>) {
    return {a, b in Task<T> {callback in function(a, b, callback) } }
}

public func thunkify<A, B, C, T>(function: (A, B, C, T -> ()) -> ()) -> ((A, B, C) -> Task<T>) {
    return {a, b, c in Task<T> {callback in function(a, b, c, callback) } }
}

public func thunkify<A, B, C, D, T>(function: (A, B, C, D, T -> ()) -> ()) -> ((A, B, C, D) -> Task<T>) {
    return {a, b, c, d in Task<T> {callback in function(a, b, c, d, callback) } }
}
