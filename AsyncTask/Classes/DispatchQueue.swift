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

//    static public func create(QOSClass: qos_class_t) -> dispatch_queue_t {
//        count += 1
//        let attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOSClass, -1)
//        return dispatch_queue_create("com.asynctask.concurrent.\(QOSClass).\(count)", attr)
//    }


    static public func getCollectionQueue() -> DispatchQueue {
        return .Custom(q)
    }

}
//let attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_DEFAULT, -1)
//let q = dispatch_queue_create("com.asynctask.collection", attr)
let q = dispatch_queue_create("com.unique.name.queue", DISPATCH_QUEUE_CONCURRENT);


var count = 0