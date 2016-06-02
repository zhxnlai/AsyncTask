//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

// TODO: await any

extension CollectionType where Generator.Element : ThrowingTaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Generator.Element.ReturnType?] {
        let dispatchTimeout = dispatch_time_t(timeInterval: timeout)
        let group = dispatch_group_create()
        let fd_sema = dispatch_semaphore_create(concurrency)

        var results = [Result<Generator.Element.ReturnType>?](count: Int(count.toIntMax()), repeatedValue: nil)
        enumerate().forEach {(index, task) in
                dispatch_group_async(group, queue.get()) {
                    dispatch_semaphore_wait(fd_sema, dispatchTimeout)
                    do {
                        if let result = try task.await(queue, timeout: timeout) {
                            results[index] = Result.Success(result)
                        } else {
                            results[index] = nil
                        }
                    } catch {
                        results[index] = Result.Failure(error)
                    }
                    dispatch_semaphore_signal(fd_sema)
                }
        }

        dispatch_group_wait(group, dispatchTimeout)

        return try results.map { value in
            guard let value = value else {return nil}
            switch value {
            case .Success(let v):
                return v
            case .Failure(let e):
                throw e
            }
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Generator.Element.ReturnType] {
        return try await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {value in value!}
    }

}

extension Dictionary where Value : ThrowingTaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Key: Value.ReturnType?] {
        let elements = Array(zip(Array(keys), try values.await(queue, concurrency: concurrency, timeout: timeout)) )
        return Dictionary<Key, Value.ReturnType?>(elements: elements)
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: Value.ReturnType] {
        let elements = try await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {(key, value) in (key, value!)}
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }
    
}

extension CollectionType where Generator.Element : TaskType {

    var throwingTasks: [ThrowingTask<Generator.Element.ReturnType>] {
        get {
            return map {ThrowingTask(task: $0)}
        }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Generator.Element.ReturnType?] {
        return try! throwingTasks.await(queue, concurrency: concurrency, timeout: timeout)
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Generator.Element.ReturnType] {
        return await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {$0!}
    }
    
}

public extension Dictionary where Value : TaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) -> [Key: Value.ReturnType?] {
        let elements = Array(zip(Array(keys), values.await(queue, concurrency: concurrency, timeout: timeout)) )
        return Dictionary<Key, Value.ReturnType?>(elements: elements)
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        let elements = await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {(key, value) in (key, value!)}
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
