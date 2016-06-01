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
//    private typealias ReturnType = 

    public func awaitFirst(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Generator.Element.ReturnType?] {
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Generator.Element.ReturnType?] {
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

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: ReturnType] {
        let elements = try await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {(key, value) in (key, value!)}
        return [Key: ReturnType](elements: elements)
    }


}

extension Dictionary where Value : ThrowingTaskType {

//    private typealias ReturnType = Value.ReturnType

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
                    if let result = try task.await(queue, timeout: timeout) {
                        results[key] = Result.Success(result)
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

        return [Key: ReturnType?](elements:
            try results.map {(key, value) in
                guard let value = value else {return (key, nil)}
                switch value {
                case .Success(let v):
                    return (key, v)
                case .Failure(let e):
                    throw e
                }
            }
        )
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: ReturnType] {
        let elements = try await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {(key, value) in (key, value!)}
        return [Key: ReturnType](elements: elements)
    }

}

public extension Array where Element : ThrowingTaskType {

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency, timeout: NSTimeInterval) throws -> [Element.ReturnType?] {
        return try indexedDictionary.await(queue, concurrency: concurrency, timeout: timeout).sortedValues
    }

    func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Element.ReturnType] {
        return try await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {$0!}
    }

}

public extension Dictionary where Value : TaskType {

    var throwingTasksDictionary: [Key: ThrowingTask<Value.ReturnType>] {
        get {
            let elements = map {($0, ThrowingTask(action: $1))}
            return [Key: ThrowingTask<Value.ReturnType>](elements: elements)
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
        return await(queue, concurrency: concurrency, timeout: DefaultTimeout).map {$0!}
    }
    
}

// internal
internal extension Dictionary where Key : Comparable {

    var sortedValues : [Value] {
        get {
            return sort({ $0.0 < $1.0 }).map({$0.1})
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

internal extension Dictionary {

    init(elements: [(Key, Value)]) {
        self.init()
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }

}
