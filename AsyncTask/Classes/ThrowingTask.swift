//
//  ThrowingTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/28/16.
//
//

import Foundation

public protocol ThrowingTaskType : BaseTaskType {
    associatedtype ReturnType

    var baseTask: BaseTask<ReturnType> { get }
    func async(queue: DispatchQueue, completion: Result<ReturnType> -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) throws -> ReturnType?
    func await(queue: DispatchQueue) throws -> ReturnType
}

extension ThrowingTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: Result<ReturnType> -> () = {_ in}) {
        return baseTask.asyncResult(queue, completion: completion)
    }

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) throws -> ReturnType? {
        return try baseTask.awaitResult(queue, timeout: timeout)?.extract()
    }

    public func await(queue: DispatchQueue = DefaultQueue) throws -> ReturnType {
        return try await(queue, timeout: TimeoutForever)!
    }

}

public class ThrowingTask<ReturnType> : ThrowingTaskType {

    public let baseTask: BaseTask<ReturnType>

    public var action: (Result<ReturnType> -> ()) -> () {
        get {
            return baseTask.action
        }
    }

    public init(action: (Result<ReturnType> -> ()) -> ()) {
        baseTask = BaseTask(action: action)
    }

    public init(action: () -> Result<ReturnType>) {
        baseTask = BaseTask(action: action)
    }

    public convenience init(action: () throws -> ReturnType) {
        self.init {(callback: Result<ReturnType> -> ()) in
            do {
                callback(Result.Success(try action()))
            } catch {
                callback(Result.Failure(error))
            }
        }
    }
    
}

