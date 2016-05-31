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

public protocol TaskType {
    associatedtype ReturnType

    var action: (ReturnType -> ()) -> () { get }
    func async(queue: DispatchQueue, completion: ReturnType -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) -> ReturnType?
    func await(queue: DispatchQueue) -> ReturnType
}

extension TaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: (ReturnType -> ()) = {_ in}) {
        dispatch_async(queue.get()) {
            self.action(completion)
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) -> ReturnType? {
        let timeout = dispatch_time_t(timeInterval: timeout)

        var value: ReturnType?
        let fd_sema = dispatch_semaphore_create(0)

        dispatch_async(queue.get()) {
            self.action {result in
                value = result
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
        return await(queue, timeout: DefaultTimeout)!
    }

}

// TODO: non escaping
public class Task<ReturnType> : TaskType {

    public let action: (ReturnType -> ()) -> ()

    public init(action: (ReturnType -> ()) -> ()) {
        self.action = action
    }

    public convenience init(action: () -> ReturnType) {
        self.init {callback in callback(action())}
    }
    
}
