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
    var task: (ReturnType -> ()) -> () { get }
    func async(queue: DispatchQueue, completion: ReturnType -> ())
    func await(queue: DispatchQueue, timeout: NSTimeInterval) -> ReturnType?
    func await(queue: DispatchQueue) -> ReturnType
}

// TODO: non escaping
public class Task<T> {

    public typealias CompletionHandler = T -> ()

    public let task: CompletionHandler -> ()

    public init(task: CompletionHandler -> ()) {
        self.task = task
    }

    public convenience init(task: () -> T) {
        self.init {callback in callback(task())}
    }

}

extension Task : TaskType {//, ThrowingTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: CompletionHandler = {_ in}) {
        dispatch_async(queue.get()) {
            self.task(completion)
        }
    }

    // sync
    public func await(queue: DispatchQueue = DefaultQueue, timeout: NSTimeInterval) -> T? {
        let timeout = dispatch_time_t(timeInterval: timeout)

        var value: T?
        let fd_sema = dispatch_semaphore_create(0)

        dispatch_async(queue.get()) {
            self.task {result in
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

    public func await(queue: DispatchQueue = DefaultQueue) -> T {
        return await(queue, timeout: DefaultTimeout)!
    }

}
