//
//  Wait.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/27/16.
//
//

import Foundation

public extension Dictionary where Value : AsyncTaskType {

    typealias ReturnType = Value.ReturnType

    func wait(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) -> [Key: ReturnType?] {
        let timeout = dispatch_time_t(timeInterval: timeout)
        let group = dispatch_group_create()

        var results = [Key: ReturnType?]()

        for (key, AsyncTask) in self {
            results.updateValue(nil, forKey: key)
            dispatch_group_async(group, queue.get()) {
                let fd_sema = dispatch_semaphore_create(0)
                AsyncTask.start(queue) {(result: Value.ReturnType) in
                    results[key] = result
                    dispatch_semaphore_signal(fd_sema)
                }
                // time individual task
                if dispatch_semaphore_wait(fd_sema, timeout) == 1 {
                    results[key] = nil
                }
            }
        }

        dispatch_group_wait(group, timeout)
        return results
    }

    func wait(queue: DispatchQueue = getDefaultQueue()) -> [Key: ReturnType] {
        var results = [Key: ReturnType]()
        for (key, value) in wait(queue, timeout: -1) {
            results.updateValue(value!, forKey: key)
        }
        return results

    }

}

public extension Array where Element : AsyncTaskType {
    func wait(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) -> [Element.ReturnType?] {
        return indexedDictionary.wait(queue, timeout: timeout).sort({ $0.0 < $1.0 }).map({$0.1})
    }

    func wait(queue: DispatchQueue = getDefaultQueue()) -> [Element.ReturnType] {
        return indexedDictionary.wait(queue).sort({ $0.0 < $1.0 }).map({$0.1})
    }
    
}

public extension AsyncTask {
    // sync
    func wait(queue: DispatchQueue, timeout: NSTimeInterval) -> T? {
        return [self].wait(queue, timeout: timeout)[0]
    }

    func wait(queue: DispatchQueue) -> T {
        return [self].wait(queue)[0]
    }

    func wait() -> T {
        return [self].wait(getDefaultQueue())[0]
    }
}
