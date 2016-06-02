//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

// TODO: await any
extension CollectionType where Generator.Element : BaseTaskType {

    public func awaitResults(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Result<Generator.Element.ReturnType>?] {
        let dispatchTimeout = dispatch_time_t(timeInterval: timeout)
        let group = dispatch_group_create()
        let fd_sema = dispatch_semaphore_create(concurrency)

        var results = [Result<Generator.Element.ReturnType>?](count: Int(count.toIntMax()), repeatedValue: nil)
        enumerate().forEach {(index, task) in
            dispatch_group_async(group, queue.get()) {
                dispatch_semaphore_wait(fd_sema, dispatchTimeout)
                if let result = task.awaitResult(queue, timeout: timeout) {
                    results[index] = result
                }
                dispatch_semaphore_signal(fd_sema)
            }
        }

        dispatch_group_wait(group, dispatchTimeout)

        return results
    }

    public func awaitResults(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Result<Generator.Element.ReturnType>] {
        return try awaitResults(queue, concurrency: concurrency, timeout: TimeoutForever).map {value in value!}
    }

}

extension CollectionType where Generator.Element : ThrowingTaskType {

    private var baseTasks : [BaseTask<Generator.Element.ReturnType>] {
        get { return map {$0.baseTask} }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Generator.Element.ReturnType?] {
            return try baseTasks.awaitResults(queue, concurrency: concurrency, timeout: timeout).map { result in
            guard let result = result else {return nil}
            switch result {
            case .Success(let v):
                return v
            case .Failure(let e):
                throw e
            }
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Generator.Element.ReturnType] {
        return try await(queue, concurrency: concurrency, timeout: TimeoutForever).map {$0!}
    }

}

extension Dictionary where Value : ThrowingTaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Key: Value.ReturnType?] {
        let elements = Array(zip(Array(keys), try values.await(queue, concurrency: concurrency, timeout: timeout)) )
        return Dictionary<Key, Value.ReturnType?>(elements: elements)
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: Value.ReturnType] {
        let elements = try await(queue, concurrency: concurrency, timeout: TimeoutForever).map {(key, value) in (key, value!)}
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }
    
}

extension CollectionType where Generator.Element : TaskType {

    private var baseTasks : [BaseTask<Generator.Element.ReturnType>] {
        get { return map {$0.baseTask} }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Generator.Element.ReturnType?] {
        return baseTasks.awaitResults(queue, concurrency: concurrency, timeout: timeout).map {result in
            guard let result = result else {return nil}
            switch result {
            case .Success(let v):
                return v
            case .Failure(let e):
                return nil
            }
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Generator.Element.ReturnType] {
        return await(queue, concurrency: concurrency, timeout: TimeoutForever).map {$0!}
    }
    
}

public extension Dictionary where Value : TaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Key: Value.ReturnType?] {
        let elements = Array(zip(Array(keys), values.await(queue, concurrency: concurrency, timeout: timeout)) )
        return Dictionary<Key, Value.ReturnType?>(elements: elements)
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        let elements = await(queue, concurrency: concurrency, timeout: TimeoutForever).map {(key, value) in (key, value!)}
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }

}

// internal
internal extension Dictionary {

    init(elements: [(Key, Value)]) {
        self.init()
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }

}
