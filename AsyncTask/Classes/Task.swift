//
//  AsyncTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

// compare promisekit, futurekit 

// Task subclass of Throwing Task?

// replace timeout with invalidate

// https://www.dartlang.org/docs/tutorials/futures/
// then

public protocol TaskType {
    associatedtype ReturnType

    var action: (ReturnType -> ()) -> () { get }
    func async(queue: DispatchQueue, completion: ReturnType -> ())
    func await(queue: DispatchQueue) -> ReturnType
}

extension TaskType {

    public var throwableTask: ThrowableTask<ReturnType> {
        return ThrowableTask<ReturnType>{callback in
            self.action {result in
                callback(Result.Success(result))
            }
        }
    }

    public func async(queue: DispatchQueue = DefaultQueue, completion: (ReturnType -> ()) = {_ in}) {
        throwableTask.asyncResult(queue) {result in
            if case let .Success(r) = result {
                completion(r)
            }
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue) -> ReturnType {
        return try! throwableTask.awaitResult(queue).extract()
    }

}

public class Task<ReturnType> : TaskType {

    public let action: (ReturnType -> ()) -> ()

    public init(action anAction: (ReturnType -> ()) -> ()) {
        action = anAction
    }

    public convenience init(action anAction: () -> ReturnType) {
        self.init {callback in callback(anAction())}
    }

}
