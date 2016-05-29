//
//  Config.swift
//  Pods
//
//  Created by Zhixuan Lai on 5/29/16.
//
//

import Foundation

internal func getDefaultQueue() -> DispatchQueue {
    return .UserInitiated
}

let defaultQueue = DispatchQueue.UserInitiated

let DefaultTimeout = NSTimeInterval(-1)

let DefaultConcurrency = Int.max