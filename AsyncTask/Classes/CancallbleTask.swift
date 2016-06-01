//
//  CancallbleTask.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/31/16.
//
//

import Foundation

public protocol CancellableTaskType : ThrowingTaskType {
//    associatedtype ReturnType
//
//    var action: (Result<ReturnType> -> ()) -> () { get }
//    func async(queue: DispatchQueue, completion: Result<ReturnType> -> ())
//    func await(queue: DispatchQueue, timeout: NSTimeInterval) throws -> ReturnType?
//    func await(queue: DispatchQueue) throws -> ReturnType

    func await(queue: DispatchQueue, cancelToken: CancelToken, timeout: NSTimeInterval) throws -> ReturnType?
    func await(queue: DispatchQueue, cancelToken: CancelToken) throws -> ReturnType
}

enum Error : ErrorType {
    case Cancel
}

public class CancelToken {

    private var cancelAction: (() -> ())?

    public init() {

    }

    func cancel() {
        cancelAction?()
    }

}

public extension CancellableTaskType {

    public func async(queue: DispatchQueue = DefaultQueue, completion: Result<ReturnType> -> () = {_ in}) {
        return Task(action: action).async(queue, completion: completion)
    }

    public func await(queue: DispatchQueue = DefaultQueue, cancelToken: CancelToken = CancelToken(), timeout: NSTimeInterval) throws -> ReturnType? {

        typealias CompletionHandler = Result<ReturnType> -> ()

        var handler: CompletionHandler!

        cancelToken.cancelAction = {
            handler(Result.Failure(Error.Cancel))
        }

        let cancelTask = Task<Result<ReturnType>> {callback in
            handler = callback
        }

        let t1 = ThrowingTask(action: Task(action: action))
        let t2 = ThrowingTask(action: cancelTask)
        return try [t1, t2].await(queue, timeout: timeout)[0]?.extract()
    }

    public func await(queue: DispatchQueue = DefaultQueue, cancelToken: CancelToken = CancelToken()) throws -> ReturnType {
        return try await(queue, timeout: DefaultTimeout)!
    }

}
// an array of two action. control one can throw
public class CancallableTask<ReturnType> : CancellableTaskType {

    public let action: (Result<ReturnType> -> ()) -> ()

    private init(action: (Result<ReturnType> -> ()) -> ()) {
        self.action = action
    }

    public convenience init(action: () throws -> ReturnType) {
        self.init {(callback: Result<ReturnType> -> ()) in
            do {
                callback(Result.Success(try action()))
            } catch {
                callback(Result.Failure(error))
            }
        }
    }

    public convenience init<T: TaskType where T.ReturnType == ReturnType>(action: T) {
        self.init{(callback: Result<ReturnType> -> ()) in
            action.action {result in
                callback(Result.Success(result))
            }
        }
    }

}

