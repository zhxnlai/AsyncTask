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

    public func async(queue: DispatchQueue = getDefaultQueue(), completion: CompletionHandler = {_ in}) {
        dispatch_async(queue.get()) {
            self.task(completion)
        }
    }

    public func async(queue: DispatchQueue = getDefaultQueue(), completion: (T?, ErrorType?) -> ()) {
        dispatch_async(queue.get()) {
            self.task {value in
                completion(value, nil)
            }
        }
    }

    // sync
    public func await(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) -> T? {
        var value: T?
        let timeout = dispatch_time_t(timeInterval: timeout)
        let fd_sema = dispatch_semaphore_create(0)
        dispatch_async(queue.get()) {
            self.task {result in
                value = result
                dispatch_sync(queue.get()) {
                    dispatch_semaphore_signal(fd_sema)
                }
            }
        }
        dispatch_semaphore_wait(fd_sema, timeout)
        return value
    }

    public func await(queue: DispatchQueue = getDefaultQueue()) -> T {
        return await(queue, timeout: -1)!
    }

}
