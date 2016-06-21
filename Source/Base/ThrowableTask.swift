//
//  BaseTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 6/1/16.
//
//

import Foundation

public enum Result<ReturnType> {

    case Success(ReturnType)
    case Failure(ErrorType)

    public func extract() throws -> ReturnType {
        switch self {
        case .Success(let value):
            return value
        case .Failure(let error):
            throw error
        }
    }
    
}

public protocol ThrowableTaskType {
    associatedtype ReturnType

    func action(completion: Result<ReturnType> -> ())
    func asyncResult(queue: DispatchQueue, completion: Result<ReturnType> -> ())
    func awaitResult(queue: DispatchQueue) -> Result<ReturnType>
    func await(queue: DispatchQueue) throws -> ReturnType
}

extension ThrowableTaskType {

    public func asyncResult(queue: DispatchQueue = DefaultQueue, completion: (Result<ReturnType> -> ()) = {_ in}) {
        dispatch_async(queue.get()) {
            self.action(completion)
        }
    }

    public func awaitResult(queue: DispatchQueue = DefaultQueue) -> Result<ReturnType> {
        let timeout = dispatch_time_t(timeInterval: TimeoutForever)

        var value: Result<ReturnType>?
        let fd_sema = dispatch_semaphore_create(0)

        dispatch_async(queue.get()) {
            self.action {result in
                value = result
                dispatch_semaphore_signal(fd_sema)
            }
        }

        dispatch_semaphore_wait(fd_sema, timeout)

        return value!
    }

    public func await(queue: DispatchQueue = DefaultQueue) throws -> ReturnType {
        return try awaitResult(queue).extract()
    }

}

public class ThrowableTask<ReturnType> : ThrowableTaskType {

    public let action: (Result<ReturnType> -> ()) -> ()

    public func action(completion: Result<ReturnType> -> ()) {
        action(completion)
    }

    public init(action anAction: (Result<ReturnType> -> ()) -> ()) {
        action = anAction
    }

    public convenience init(action: () -> Result<ReturnType>) {
        self.init {callback in callback(action())}
    }

    public convenience init(action: (ReturnType -> ()) throws -> ()) {
        self.init {(callback: Result<ReturnType> -> ()) in
            do {
                try action {result in
                    callback(Result.Success(result))
                }
            } catch {
                callback(Result.Failure(error))
            }
        }
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
