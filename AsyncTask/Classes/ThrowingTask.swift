//
//  ThrowingTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/28/16.
//
//

import Foundation

public protocol ThrowingTaskType {
    associatedtype ReturnType
    func async(queue: DispatchQueue, completion: (ReturnType?, ErrorType?) -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) throws -> ReturnType?
    func await(queue: DispatchQueue) throws -> ReturnType
}


internal enum Result<T> {
    case Success(T)
    case Failure(ErrorType)

    func toTuple() -> (T?, ErrorType?) {
        switch self {
        case .Success(let v):
            return (v, nil)
        case .Failure(let e):
            return (nil, e)
        }
    }
}

public class ThrowingTask<T> {

    private let task: Task<Result<T>>

    private init(task: (Result<T> -> ()) -> ()) {
        self.task = Task(task: task)
    }

    public convenience init<V: TaskType where V.ReturnType == T>(task: V) {
        self.init {(callback: Result<T> -> ()) in
            task.task {value in
                callback(Result.Success(value))
            }
        }
    }

    public convenience init(task: () throws -> T) {
        self.init {(callback: Result<T> -> ()) in
            do {
                callback(Result.Success(try task()))
            } catch {
                callback(Result.Failure(error))
            }
        }
    }

}

extension ThrowingTask : ThrowingTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: (T?, ErrorType?) -> () = {_ in}) {
        return task.async(queue) {result in
            result.toTuple()
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) throws -> T? {
        guard let r = task.await(queue, timeout: timeout) else { return nil }
        switch r {
        case let .Success(result):
            return result
        case let .Failure(error):
            throw error
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue) throws -> T {
        return try await(queue, timeout: DefaultTimeout)!
    }

}

