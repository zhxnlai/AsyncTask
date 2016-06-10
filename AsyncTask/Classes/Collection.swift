//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

extension CollectionType where Generator.Element : BaseTaskType {

    public func awaitFirstResult(queue: DispatchQueue = DefaultQueue) -> Result<Generator.Element.ReturnType> {
        let tasks = map{$0}
        return Task {(callback: Result<Generator.Element.ReturnType> -> ()) in
            tasks.asyncForEach(queue, transform: {task in task.awaitResult()}) { index, result in
                callback(result)
            }
        }.await(queue)
    }

    public func awaitAllResults(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Result<Generator.Element.ReturnType>] {
        let tasks = map{$0}
        return tasks.concurrentMap(queue) {task in task.awaitResult()}
    }

}

extension CollectionType where Generator.Element : ThrowingTaskType {

    private var baseTasks : [BaseTask<Generator.Element.ReturnType>] {
        get { return map {$0.baseTask} }
    }

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) throws -> Generator.Element.ReturnType {
        return try baseTasks.awaitFirstResult(queue).extract()
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Generator.Element.ReturnType] {
        return try baseTasks.awaitAllResults(queue, concurrency: concurrency).map { result in try result.extract() }
    }

}

extension Dictionary where Value : ThrowingTaskType {

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) throws -> Value.ReturnType {
        return try values.awaitFirstResult(queue).extract()
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), try values.awaitAll(queue, concurrency: concurrency)) )
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }
    
}

extension CollectionType where Generator.Element : TaskType {

    private var baseTasks : [BaseTask<Generator.Element.ReturnType>] {
        get { return map {$0.baseTask} }
    }

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) -> Generator.Element.ReturnType {
        return try! baseTasks.awaitFirstResult(queue).extract()
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Generator.Element.ReturnType] {
        return baseTasks.awaitAllResults(queue, concurrency: concurrency).map {result in try! result.extract() }
    }

}

public extension Dictionary where Value : TaskType {

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) -> Value.ReturnType {
        return try! values.awaitFirstResult(queue).extract()
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), values.awaitAll(queue, concurrency: concurrency)))
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

extension Array {

    func asyncForEach<U>(queue: DispatchQueue, transform: Element -> U, completion: (Int, U) -> ()) {
        let fd_sema = dispatch_semaphore_create(0)

        var c = 0
        let tt = count

        for (index, item) in enumerate() {
            dispatch_async(queue.get()) {
                let result = transform(self[index])
                dispatch_sync(DispatchQueue.getCollectionQueue().get()) {
                    completion(index, result)
                    c = c + 1
                    if c == tt {
                        dispatch_semaphore_signal(fd_sema)
                    }
                }
            }
        }

        dispatch_semaphore_wait(fd_sema, dispatch_time_t(timeInterval: -1))
    }

    func concurrentMap<U>(queue: DispatchQueue, transform: Element -> U) -> [U] {
        let fd_sema = dispatch_semaphore_create(0)

        var results = [U?](count: count, repeatedValue: nil)
        var c = 0
        let tt = count

        dispatch_apply(count, queue.get()) {index in
            let result = transform(self[index])
            dispatch_sync(DispatchQueue.getCollectionQueue().get()) {
                results[index] = result
                c = c + 1
                if c == tt {
                    dispatch_semaphore_signal(fd_sema)
                }
            }
        }

        dispatch_semaphore_wait(fd_sema, dispatch_time_t(timeInterval: -1))
        return results.flatMap {$0}
    }

}

