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

internal enum Result<ReturnType> {

    case Success(ReturnType)
    case Failure(ErrorType)

    var tuple : (ReturnType?, ErrorType?) {
        get {
            switch self {
            case .Success(let result):
                return (result, nil)
            case .Failure(let error):
                return (nil, error)
            }
        }
    }

}

public class ThrowingTask<ReturnType> {

    private let task: Task<Result<ReturnType>>

    private init(task: Task<Result<ReturnType>>) {
        self.task = task
    }

    public convenience init(task: () throws -> ReturnType) {
        self.init(task: Task {(callback: Result<ReturnType> -> ()) in
            do {
                callback(Result.Success(try task()))
            } catch {
                callback(Result.Failure(error))
            }
            }
        )
    }

    public convenience init<T: TaskType where T.ReturnType == ReturnType>(task: T) {
        self.init(task: Task {(callback: Result<ReturnType> -> ()) in
                task.task {result in
                    callback(Result.Success(result))
                }
            }
        )
    }

}

extension ThrowingTask : ThrowingTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: (ReturnType?, ErrorType?) -> () = {_ in}) {
        return task.async(queue) {result in
            result.tuple
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) throws -> ReturnType? {
        guard let r = task.await(queue, timeout: timeout) else { return nil }
        switch r {
        case let .Success(result):
            return result
        case let .Failure(error):
            throw error
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue) throws -> ReturnType {
        return try await(queue, timeout: DefaultTimeout)!
    }

}

