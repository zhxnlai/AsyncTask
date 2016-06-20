//
//  Misc.swift
//  Pods
//
//  Created by Zhixuan Lai on 3/1/16.
//
//

import Foundation

internal extension dispatch_time_t {
    init(timeInterval: NSTimeInterval) {
        self.init(timeInterval < NSTimeInterval(0) ? DISPATCH_TIME_FOREVER : dispatch_time(DISPATCH_TIME_NOW, Int64(timeInterval * Double(NSEC_PER_SEC))))
    }
}
