//
//  ThrowingTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/28/16.
//
//

import Foundation

public enum Result<ReturnType> {

    case Success(ReturnType)
    case Failure(ErrorType)

    func extract() throws -> ReturnType {
        switch self {
        case .Success(let value):
            return value
        case .Failure(let error):
            throw error
        }
    }

}

public protocol ThrowingTaskType {
    associatedtype ReturnType

    var task: (Result<ReturnType> -> ()) -> () { get }
    func async(queue: DispatchQueue, completion: Result<ReturnType> -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) throws -> ReturnType?
    func await(queue: DispatchQueue) throws -> ReturnType
}

extension ThrowingTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: Result<ReturnType> -> () = {_ in}) {
        return Task(task: task).async(queue, completion: completion)
    }

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) throws -> ReturnType? {
        return try Task(task: task).await(queue, timeout: timeout)?.extract()
    }

    public func await(queue: DispatchQueue = DefaultQueue) throws -> ReturnType {
        return try await(queue, timeout: DefaultTimeout)!
    }
    
}

public class ThrowingTask<ReturnType> : ThrowingTaskType {

    public let task: (Result<ReturnType> -> ()) -> ()

    private init(task: (Result<ReturnType> -> ()) -> ()) {
        self.task = task
    }

    public convenience init(task: () throws -> ReturnType) {
        self.init {(callback: Result<ReturnType> -> ()) in
            do {
                callback(Result.Success(try task()))
            } catch {
                callback(Result.Failure(error))
            }
        }
    }

    public convenience init<T: TaskType where T.ReturnType == ReturnType>(task: T) {
        self.init{(callback: Result<ReturnType> -> ()) in
                task.task {result in
                    callback(Result.Success(result))
                }
            }
    }

}

