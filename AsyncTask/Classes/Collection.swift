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

    public func awaitFirstResult(queue: DispatchQueue = DefaultQueue) -> Result<Generator.Element.ReturnType> {
        let dispatchTimeout = dispatch_time_t(timeInterval: TimeoutForever)
        let collectionQueue = DispatchQueue.Custom(DispatchQueue.create(QOS_CLASS_USER_INTERACTIVE))
        let tasks = map{$0}

        return Task {
            let fd_sema = dispatch_semaphore_create(0)

            var result : Result<Generator.Element.ReturnType>?
            for task in tasks {
                dispatch_async(collectionQueue.get()) {
                    result = task.awaitResult(queue)
                    dispatch_semaphore_signal(fd_sema)
                }
            }

            dispatch_semaphore_wait(fd_sema, dispatchTimeout)
            return result!
        }.await(collectionQueue)
    }

    public func awaitResults(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Result<Generator.Element.ReturnType>] {
        let dispatchTimeout = dispatch_time_t(timeInterval: TimeoutForever)
        let collectionQueue = DispatchQueue.getCollectionQueue()
        let tasks = map{$0}

        return Task {(callback: ([Result<Generator.Element.ReturnType>] -> () )) in
//            let fd_sema = dispatch_semaphore_create(concurrency)
//
//            var results = [Result<Generator.Element.ReturnType>?](count: tasks.count, repeatedValue: nil)
            //[Result<Generator.Element.ReturnType>?](count: tasks.count, repeatedValue: nil) as NSDictionary

//            dispatch_apply(tasks.count, queue.get()) {index in
//                dispatch_semaphore_wait(fd_sema, dispatchTimeout)
//                let r = tasks[index].awaitResult(queue)
//                results[index] = r
//                dispatch_semaphore_signal(fd_sema)
//                print(index)
//            }

            tasks.concurrentMap({task in task.awaitResult(queue)}, callback: callback)

//            let fd_sema2 = dispatch_semaphore_create(0)
//
//            for (index, task) in tasks.enumerate() {
//                dispatch_semaphore_wait(fd_sema, dispatchTimeout)
//                task.asyncResult(queue) {r in
//                    results[index] = r
//                    d[index] = r
//                    print(index)
//                    dispatch_semaphore_signal(fd_sema)
//                    dispatch_semaphore_signal(fd_sema2)
//                }
//            }
//
//            for i in 0..<tasks.count {
//                dispatch_semaphore_wait(fd_sema2, dispatchTimeout)
//            }

//            print(results.count, d.count)
//            return results.flatMap { result in result }
        }.await(queue)
    }

}

extension CollectionType where Generator.Element : ThrowingTaskType {

    private var baseTasks : [BaseTask<Generator.Element.ReturnType>] {
        get { return map {$0.baseTask} }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Generator.Element.ReturnType] {
            return try baseTasks.awaitResults(queue, concurrency: concurrency).map { result in
            switch result {
            case .Success(let v):
                return v
            case .Failure(let e):
                throw e
            }
        }
    }

}

extension Dictionary where Value : ThrowingTaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) throws -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), try values.await(queue, concurrency: concurrency)) )
        return Dictionary<Key, Value.ReturnType>(elements: elements)
    }
    
}

extension CollectionType where Generator.Element : TaskType {

    private var baseTasks : [BaseTask<Generator.Element.ReturnType>] {
        get { return map {$0.baseTask} }
    }

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Generator.Element.ReturnType] {
        return baseTasks.awaitResults(queue, concurrency: concurrency).map {result in
            switch result {
            case .Success(let v):
                return v
            case .Failure(let e):
                fatalError("Should be unreachable")
            }
        }
    }

}

public extension Dictionary where Value : TaskType {

    public func await(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Key: Value.ReturnType] {
        let elements = Array(zip(Array(keys), values.await(queue, concurrency: concurrency)))
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

func synchronized(sync: AnyObject, fn: ()->()) {
    objc_sync_enter(sync)
    fn()
    objc_sync_exit(sync)
}

extension Array {

    func concurrentMap<U>(transform: Element -> U,
                       callback: [U] -> ()) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        let sync = NSObject()
        var index = 0;

        // populate the array
        let r = transform(self[0])
        var results = Array<U>(count: self.count, repeatedValue:r)

        for (index, item) in enumerate().dropFirst() {
            dispatch_group_async(group, queue) {
                let r = transform(item)
                synchronized(sync) {
                    results[index] = r
                }
            }
        }
        
        dispatch_group_notify(group, queue) {
            callback(results)
        }
    }
}

