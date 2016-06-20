//
//  NSURLSessionDataTask+Task.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 6/15/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AsyncTask

extension NSURL : ThrowableTaskType {

    public typealias ReturnType = (NSData, NSURLResponse)
    public func action(completion: Result<ReturnType> -> ()) {
        ThrowableTask<ReturnType> {
            let session = NSURLSession(configuration: .ephemeralSessionConfiguration())
            let (data, response, error) = Task { callback in session.dataTaskWithURL(self, completionHandler: callback).resume()}.await()
            guard error == nil else { throw error! }
            return (data!, response!)
        }.asyncResult(completion: completion)
    }
    
}
