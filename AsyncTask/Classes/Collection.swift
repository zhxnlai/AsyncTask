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

    public func await(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) throws -> [Key: ReturnType?] {
        let group = dispatch_group_create()
        var results = [Key: Result<ReturnType>?]()
        for (key, task) in self {
            results.updateValue(nil, forKey: key)
            dispatch_group_async(group, queue.get()) {
                do {
                    if let r = try task.await(queue, timeout: timeout) {
                        results[key] = Result.Success(r)
                    } else {
                        results[key] = nil
                    }
                } catch {
                    results[key] = Result.Failure(error)
                }
            }
        }

        dispatch_group_wait(group, dispatch_time_t(timeInterval: timeout))

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

    public func await(queue: DispatchQueue = getDefaultQueue()) throws -> [Key: ReturnType] {
        var results = [Key: ReturnType]()
        for (key, value) in try await(queue, timeout: -1) {
            results.updateValue(value!, forKey: key)
        }
        return results
    }

}

public extension Array where Element : ThrowingTaskType {

    func await(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) throws -> [Element.ReturnType?] {
        return try indexedDictionary.await(queue, timeout: timeout).sort({ $0.0 < $1.0 }).map({$0.1})
    }

    func await(queue: DispatchQueue = getDefaultQueue()) throws -> [Element.ReturnType] {
        return try indexedDictionary.await(queue).sort({ $0.0 < $1.0 }).map({$0.1})
    }

}

public extension Dictionary where Value : TaskType {

    func toThrowingTasks() -> [Key: ThrowingTask<Value.ReturnType>] {
        var ret = [Key: ThrowingTask<Value.ReturnType>]()
        for (key, value) in self {
            ret.updateValue(ThrowingTask(task: value), forKey: key)
        }
        return ret
    }

    func await(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) -> [Key: Value.ReturnType?] {
        return try! toThrowingTasks().await(queue, timeout: timeout)
    }

    func await(queue: DispatchQueue = getDefaultQueue()) -> [Key: Value.ReturnType] {
        return try! toThrowingTasks().await(queue)
    }

}

public extension Array where Element : TaskType {

    func await(queue: DispatchQueue = getDefaultQueue(), timeout: NSTimeInterval) -> [Element.ReturnType?] {
        return indexedDictionary.await(queue, timeout: timeout).sort({ $0.0 < $1.0 }).map({$0.1})
    }

    func await(queue: DispatchQueue = getDefaultQueue()) -> [Element.ReturnType] {
        return indexedDictionary.await(queue).sort({ $0.0 < $1.0 }).map({$0.1})
    }
    
}
