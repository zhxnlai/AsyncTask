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

    var baseTask: BaseTask<ReturnType> { get }
    func async(queue: DispatchQueue, completion: ReturnType -> ())
    func await(queue: DispatchQueue) -> ReturnType
}

extension TaskType {

    public var baseTask: BaseTask<ReturnType> {
        get {
            return BaseTask<ReturnType>(action: action)
        }
    }

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

    public let action: (Result<ReturnType> -> ()) -> ()

    public init(action anAction: (ReturnType -> ()) -> ()) {
        action = {callback in
            anAction {r in
                callback(Result.Success(r))
            }
        }
    }

    public convenience init(action anAction: () -> ReturnType) {
        self.init {callback in callback(anAction())}
    }

}
