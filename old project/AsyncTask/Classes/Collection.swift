//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

extension SequenceType where Generator.Element : ThrowableTaskType {

    public func awaitFirstResult(queue: DispatchQueue = DefaultQueue) -> Result<Generator.Element.ReturnType> {
        let tasks = map{$0}
        return Task {(callback: Result<Generator.Element.ReturnType> -> ()) in
            tasks.concurrentForEach(queue, transform: {task in task.awaitResult()}) { index, result in
                callback(result)
            }
        }.await(queue)
    }

    public func awaitAllResults(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Result<Generator.Element.ReturnType>] {
        let tasks = map{$0}
        return tasks.concurrentMap(queue, concurrency: concurrency) {task in task.awaitResult()}
    }

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) throws -> Generator.Element.ReturnType {
        return try awaitFirstResult(queue).extract()
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Generator.Element.ReturnType] {
        return try awaitAllResults(queue, concurrency: concurrency).map {try $0.extract()}
    }

}

extension Dictionary where Value : ThrowableTaskType {

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) throws -> Value.ReturnType {
        return try values.awaitFirst(queue)
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), try values.awaitAll(queue, concurrency: concurrency)))
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }
    
}

extension SequenceType where Generator.Element : TaskType {

    var throwableTasks: [ThrowableTask<Generator.Element.ReturnType>] {
        return map {$0.throwableTask}
    }

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) -> Generator.Element.ReturnType {
        return try! throwableTasks.awaitFirstResult(queue).extract()
    }

    public func awaitAll(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Generator.Element.ReturnType] {
        return throwableTasks.awaitAllResults(queue, concurrency: concurrency).map {result in try! result.extract() }
    }

}

extension Dictionary where Value : TaskType {

    var throwableTasks: [ThrowableTask<Value.ReturnType>] {
        return values.throwableTasks
    }

    public func awaitFirst(queue: DispatchQueue = DefaultQueue) -> Value.ReturnType {
        return try! throwableTasks.awaitFirstResult(queue).extract()
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), try! throwableTasks.awaitAll(queue, concurrency: concurrency)))
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }

}

extension Dictionary {

    init(elements: [(Key, Value)]) {
        self.init()
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }

}

extension Array {

    func concurrentForEach<U>(queue: DispatchQueue, transform: Element -> U, completion: (Int, U) -> ()) {
        let fd_sema = dispatch_semaphore_create(0)

        var numberOfCompletedTasks = 0
        let numberOfTasks = count

        for (index, item) in enumerate() {
            dispatch_async(queue.get()) {
                let result = transform(item)
                dispatch_sync(DispatchQueue.getCollectionQueue().get()) {
                    completion(index, result)
                    numberOfCompletedTasks += 1
                    if numberOfCompletedTasks == numberOfTasks {
                        dispatch_semaphore_signal(fd_sema)
                    }
                }
            }
        }

        dispatch_semaphore_wait(fd_sema, dispatch_time_t(timeInterval: -1))
    }

    func concurrentMap<U>(queue: DispatchQueue, concurrency: Int, transform: Element -> U) -> [U] {
        let fd_sema = dispatch_semaphore_create(0)
        let fd_sema2 = dispatch_semaphore_create(concurrency)

        var results = [U?](count: count, repeatedValue: nil)
        var numberOfCompletedTasks = 0
        let numberOfTasks = count

        dispatch_apply(count, queue.get()) {index in
            dispatch_semaphore_wait(fd_sema2, dispatch_time_t(timeInterval: -1))
            let result = transform(self[index])
            dispatch_sync(DispatchQueue.getCollectionQueue().get()) {
                results[index] = result
                numberOfCompletedTasks += 1
                if numberOfCompletedTasks == numberOfTasks {
                    dispatch_semaphore_signal(fd_sema)
                }
                dispatch_semaphore_signal(fd_sema2)
            }
        }

        dispatch_semaphore_wait(fd_sema, dispatch_time_t(timeInterval: -1))
        return results.flatMap {$0}
    }

}

