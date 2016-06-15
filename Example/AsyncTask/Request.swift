//
//  Request.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 6/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AsyncTask

class Request {

    enum State {
        case Pending, Running, Finished(NSData)

        var description : String {
            switch self {
            case .Pending: return "Pending";
            case .Running: return "Running";
            case .Finished: return "Finished";
            }
        }
    }

    private(set) var state: State = .Pending
    let URL: NSURL
    var didChange = {}

    init(URL aURL: NSURL) {
        URL = aURL
    }

}

extension Request : TaskType {

    typealias ReturnType = NSData
    func action(completion: ReturnType -> ()) {
        Task<ReturnType> {[unowned self] in
            self.state = .Running
            self.didChange()
            let data = get(self.URL).await()
            self.state = .Finished(data)
            self.didChange()
            return data
        }.async(completion: completion)
    }

}