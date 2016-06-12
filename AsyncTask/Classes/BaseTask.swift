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

public protocol BaseTaskType {
    associatedtype ReturnType

    var action: (Result<ReturnType> -> ()) -> () { get }
    func asyncResult(queue: DispatchQueue, completion: Result<ReturnType> -> ())
    func awaitResult(queue: DispatchQueue) -> Result<ReturnType>
}

extension BaseTaskType {

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

}

public class BaseTask<ReturnType> : BaseTaskType {

    public let action: (Result<ReturnType> -> ()) -> ()

    public init(action anAction: (Result<ReturnType> -> ()) -> ()) {
        action = anAction
    }

    public convenience init(action: () -> Result<ReturnType>) {
        self.init {callback in callback(action())}
    }
    
}

