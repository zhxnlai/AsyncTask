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

    var action: (Result<ReturnType> -> ()) -> () { get }
    func async(queue: DispatchQueue, completion: Result<ReturnType> -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) throws -> ReturnType?
    func await(queue: DispatchQueue) throws -> ReturnType
}

extension ThrowingTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: Result<ReturnType> -> () = {_ in}) {
        return Task(action: action).async(queue, completion: completion)
    }

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) throws -> ReturnType? {
        return try Task(action: action).await(queue, timeout: timeout)?.extract()
    }

    public func await(queue: DispatchQueue = DefaultQueue) throws -> ReturnType {
        return try await(queue, timeout: DefaultTimeout)!
    }
    
}

public class ThrowingTask<ReturnType> : ThrowingTaskType {

    public let action: (Result<ReturnType> -> ()) -> ()

    private init(action: (Result<ReturnType> -> ()) -> ()) {
        self.action = action
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

    public convenience init<T: TaskType where T.ReturnType == ReturnType>(task: T) {
        self.init{(callback: Result<ReturnType> -> ()) in
            task.action {result in
                callback(Result.Success(result))
            }
        }
    }
    
}

