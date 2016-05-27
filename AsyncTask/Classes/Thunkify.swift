//
//  Thunkify.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

public extension AsyncTask {

    static func thunkify<A, T>(function: (A, T -> ()) -> ()) -> (A -> AsyncTask<T>) {
        return {a in AsyncTask<T> {callback in function(a, callback) } }
    }

    static func thunkify<A, B, T>(function: (A, B, T -> ()) -> ()) -> ((A, B) -> AsyncTask<T>) {
        return {a, b in AsyncTask<T> {callback in function(a, b, callback) } }
    }

    static func thunkify<A, B, C, T>(function: (A, B, C, T -> ()) -> ()) -> ((A, B, C) -> AsyncTask<T>) {
        return {a, b, c in AsyncTask<T> {callback in function(a, b, c, callback) } }
    }

    static func thunkify<A, B, C, D, T>(function: (A, B, C, D, T -> ()) -> ()) -> ((A, B, C, D) -> AsyncTask<T>) {
        return {a, b, c, d in AsyncTask<T> {callback in function(a, b, c, d, callback) } }
    }
    
}
