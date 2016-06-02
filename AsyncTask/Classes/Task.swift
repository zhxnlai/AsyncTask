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

public protocol TaskType : BaseTaskType {
    associatedtype ReturnType

    var baseTask: BaseTask<ReturnType> { get }
    func async(queue: DispatchQueue, completion: ReturnType -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) -> ReturnType?
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

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) -> ReturnType? {
        let timeout = dispatch_time_t(timeInterval: timeout)

        var value: ReturnType?
        let fd_sema = dispatch_semaphore_create(0)

        baseTask.asyncResult(queue) {result in
            if case let .Success(r) = result {
                value = r
                dispatch_semaphore_signal(fd_sema)
            }
        }

        dispatch_semaphore_wait(fd_sema, timeout)

        // synchronize the variable
        dispatch_sync(queue.get()) {
            _ = value
        }
        return value
    }

    public func await(queue: DispatchQueue = DefaultQueue) -> ReturnType {
        return await(queue, timeout: TimeoutForever)!
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
