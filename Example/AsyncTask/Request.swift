//
//  Request.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 6/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AsyncTask

class Request : TaskType {

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

    typealias ReturnType = NSData
    typealias ActionType = (Result<NSData> -> ()) -> ()

    var action: ActionType { get {return task.action} }
    var task: Task<NSData>!

    var didChange = {}

    init(URL aURL: NSURL) {
        URL = aURL
        task = Task<NSData> {
            self.state = .Running
            self.didChange()
            let data = get(self.URL).await()
            self.state = .Finished(data)
            self.didChange()
            return data
        }
    }

}
