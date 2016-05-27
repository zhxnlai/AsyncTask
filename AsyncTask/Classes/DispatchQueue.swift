//
//  Misc.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/26/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import Foundation

// https://developer.apple.com/library/ios/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html#//apple_ref/doc/uid/TP40015243-CH39-SW39
@available(iOS 8.0, OSX 10.10, *)
public enum DispatchQueue {

    case Main
    case UserInteractive    // Work is virtually instantaneous.
    case UserInitiated      // Work is nearly instantaneous, such as a few seconds or less.
    case Utility            // Work takes a few seconds to a few minutes.
    case Background         // Work takes significant time, such as minutes or hours.
    case Custom(dispatch_queue_t)

    public func get() -> dispatch_queue_t {
        switch self {
        case .Main:
            return dispatch_get_main_queue()
        case .UserInteractive:
            return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        case .UserInitiated:
            return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        case .Utility:
            return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        case .Background:
            return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        case .Custom(let queue):
            return queue
        }
    }

}
