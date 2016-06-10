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
        let tasks = map{$0}
        return Task {(callback: Result<Generator.Element.ReturnType> -> ()) in
            tasks.asyncForEach {task in callback(task.awaitResult(queue))}
        }.await(queue)
    }

    public func awaitAllResults(queue: DispatchQueue = DefaultQueue, concurrency: Int = DefaultConcurrency) -> [Result<Generator.Element.ReturnType>] {
        let tasks = map{$0}

//        let group = dispatch_group_create()
//        let sync = NSObject()
//        var index = 0;
//
//        // populate the array
//        var results = [Result<Generator.Element.ReturnType>?](count: tasks.count, repeatedValue:nil)
//
//        for (index, task) in tasks.enumerate() {
//            dispatch_group_async(group, DispatchQueue.Background.get()) {
//                let r = task.awaitResult(queue)
//                print(index)
////                synchronized(sync) {
//                    results[index] = r
////                }
//            }
//        }
//
////        dispatch_group_notify(group, specialQueue.get()) {
////            callback(results.flatMap {$0})
////        }
//
//        dispatch_group_wait(group, dispatch_time_t(timeInterval: -1))
//
//        return results.flatMap {$0}


        return Task {//(callback: ([Result<Generator.Element.ReturnType>] -> () )) in
//            tasks.enumerate().map({$0}).concurrentMap({(index, task) in
//                print("---\(index)")
//                return task.awaitResult(queue)
//                }, callback: callback)

            let fd_sema = dispatch_semaphore_create(0)

//            let group = dispatch_group_create()
            let sync = NSObject()
//            var index = 0;

            // populate the array
            var results = [Result<Generator.Element.ReturnType>?](count: tasks.count, repeatedValue:nil)

            dispatch_apply(tasks.count, queue.get()) {index in
                print("submit \(index)")
                let r = tasks[index].awaitResult(queue)
                print("finished \(index)")
                synchronized(sync) {
                    print("saved---\(index)")
                    results[index] = r
                    dispatch_semaphore_signal(fd_sema)
                }
            }
//            for (index, task) in tasks.enumerate() {
//
//                dispatch_async(queue.get()) {
//                    print("submit \(index)")
//                    let r = task.awaitResult(queue)
//                    print("finished \(index)")
//                    synchronized(sync) {
//                        print("saved---\(index)")
//                        results[index] = r
//                        dispatch_semaphore_signal(fd_sema)
//                    }
//                }
//            }

            for i in 0..<tasks.count {

//                print("f---\(i)")
                print("waited---\(i)")
                dispatch_semaphore_wait(fd_sema, dispatch_time_t(timeInterval: -1))
            }

            return results.flatMap {$0}
//            dispatch_group_notify(group, specialQueue.get()) {
//                callback(results.flatMap {$0})
//            }

//            dispatch_group_wait(group, dispatch_time_t(timeInterval: -1))

        }.await(queue)
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

func synchronized(sync: AnyObject, fn: ()->()) {
    objc_sync_enter(sync)
    fn()
    objc_sync_exit(sync)
}

extension Array {

    func asyncForEach(body: Element -> Void) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

        for (index, item) in enumerate() {
            dispatch_async(queue) {
                body(item)
            }
        }
    }

    func concurrentMap<U>(transform: Element -> U, callback: [U] -> ()) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let group = dispatch_group_create()
        let sync = NSObject()
        var index = 0;

        // populate the array
        var results = Array<U?>(count: count, repeatedValue:nil)

        for (index, item) in enumerate() {
            dispatch_group_async(group, queue) {
                let r = transform(item)
                print(index)
                synchronized(sync) {
                    results[index] = r
                }
            }
        }
        
        dispatch_group_notify(group, queue) {
            callback(results.flatMap {$0})
        }
    }

}

