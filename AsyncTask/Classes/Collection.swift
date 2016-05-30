//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

extension Dictionary where Value : ThrowingTaskType {

    private typealias ReturnType = Value.ReturnType

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Key: ReturnType?] {
        let dispatchTimeout = dispatch_time_t(timeInterval: timeout)
        let group = dispatch_group_create()
        let fd_sema = dispatch_semaphore_create(concurrency)

        var results = [Key: Result<ReturnType>?]()
        for (key, task) in self {
            results.updateValue(nil, forKey: key)
            dispatch_group_async(group, queue.get()) {
                dispatch_semaphore_wait(fd_sema, dispatchTimeout)
                do {
                    if let r = try task.await(queue, timeout: timeout) {
                        results[key] = Result.Success(r)
                    } else {
                        results[key] = nil
                    }
                } catch {
                    results[key] = Result.Failure(error)
                }

                dispatch_semaphore_signal(fd_sema)
            }
        }

        dispatch_group_wait(group, dispatchTimeout)

        var ret = [Key: ReturnType?]()

        for (key, value) in results {
            if let result = value {
                switch result {
                case .Success(let v):
                    ret[key] = v
                case .Failure(let e):
                    throw e
                }
            } else {
                ret.updateValue(nil, forKey: key)
            }
        }

        return ret
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: ReturnType] {
        var results = [Key: ReturnType]()
        for (key, value) in try await(queue, concurrency: concurrency, timeout: DefaultTimeout) {
            results.updateValue(value!, forKey: key)
        }
        return results
    }

}

public extension Array where Element : ThrowingTaskType {

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Element.ReturnType?] {
        return try indexedDictionary.await(queue, concurrency: concurrency, timeout: timeout).sortedValues
    }

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Element.ReturnType] {
        return try indexedDictionary.await(queue, concurrency: concurrency).sortedValues
    }

}

public extension Dictionary where Value : TaskType {

    var throwingTasksDictionary: [Key: ThrowingTask<Value.ReturnType>] {
        get {
            var ret = [Key: ThrowingTask<Value.ReturnType>]()
            for (key, value) in self {
                ret.updateValue(ThrowingTask(task: value), forKey: key)
            }
            return ret
        }
    }

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Key: Value.ReturnType?] {
        return try! throwingTasksDictionary.await(queue, concurrency: concurrency, timeout: timeout)
    }

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        return try! throwingTasksDictionary.await(queue, concurrency: concurrency)
    }

}

public extension Array where Element : TaskType {

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Element.ReturnType?] {
        return indexedDictionary.await(queue, concurrency: concurrency, timeout: timeout).sortedValues
    }

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Element.ReturnType] {
        return indexedDictionary.await(queue, concurrency: concurrency).sortedValues
    }
    
}

// internal
internal extension Dictionary where Key : Comparable {

    var sortedValues : [Value] {
        get {
            return self.sort({ $0.0 < $1.0 }).map({$0.1})
        }
    }
    
}

internal extension Array {

    var indexedDictionary: [Int: Element] {
        var result = [Int: Element]()
        for (index, element) in enumerate() {
            result[index] = element
        }
        return result
    }

}

