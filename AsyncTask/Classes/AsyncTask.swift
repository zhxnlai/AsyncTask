//
//  AsyncTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

public protocol AsyncTaskType {
    associatedtype ReturnType
    var task: (ReturnType -> ()) -> () { get }
    func start(queue: DispatchQueue, completion: ReturnType -> ())
}


// TODO: non escaping
public class AsyncTask<T> : AsyncTaskType {

    public typealias CompletionHandler = T -> ()

    public let task: CompletionHandler -> ()

    public init(task: CompletionHandler -> ()) {
        self.task = task
    }

    public convenience init(task: () -> T) {
        self.init {callback in callback(task())}
    }

    // return async
    public func start(queue: DispatchQueue = getDefaultQueue(), completion: CompletionHandler = {_ in}) {
        dispatch_async(queue.get()) {
            self.task(completion)
        }
    }

}


public extension AsyncTask {

    public static func throwable<T>(task: () throws -> T) -> AsyncTask<(T?, ErrorType?)> {
        return AsyncTask<(T?, ErrorType?)> {() -> (T?, ErrorType?) in
            do {
                return (try task(), nil)
            } catch {
                return (nil, error)
            }
        }
    }

}


//postfix func ~~~<T> (function: AsyncTask<T>) -> T {
//    return function.wait()
//}

//prefix func ±<T> (value: AsyncTask<T>) -> T {
//    return value.wait()
//}


//extension AsyncTask {
//    var defaultQueue: DispatchQueue {
//        get {
//            return .UserInitiated
//        }
//    }
//}
