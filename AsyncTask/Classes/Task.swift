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

public protocol TaskType : BaseTaskType {
    associatedtype ReturnType

    var baseTask: BaseTask<ReturnType> { get }
    func async(queue: DispatchQueue, completion: ReturnType -> ())
    func await(queue: DispatchQueue) -> ReturnType
}

extension TaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: (ReturnType -> ()) = {_ in}) {
        baseTask.asyncResult(queue) {result in
            if case let .Success(r) = result {
                completion(r)
            }
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue) -> ReturnType {
        return try! baseTask.awaitResult(queue).extract()
    }

}

public class Task<ReturnType> : TaskType {

    public let baseTask: BaseTask<ReturnType>

    public var action: (Result<ReturnType> -> ()) -> () {
        get {
            return baseTask.action
        }
    }

    public init(action: (ReturnType -> ()) -> ()) {
        baseTask = BaseTask<ReturnType> {callback in
            action {r in
                callback(Result.Success(r))
            }
        }
    }

    public convenience init(action: () -> ReturnType) {
        self.init {callback in callback(action())}
    }

}
