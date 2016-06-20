//
//  Misc.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/24/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import Foundation
import UIKit
import AsyncTask

let session = NSURLSession(configuration: .ephemeralSessionConfiguration())

let get = {(URL: NSURL) -> Task<NSData> in
    Task {
        let (data, _, _) = Task {callback in session.dataTaskWithURL(URL, completionHandler: callback).resume()}.await()
        return data!
    }
}

extension CGFloat {
    static func random(lower: CGFloat = 0.0, upper: CGFloat = 1.0) -> CGFloat {
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return (r * (upper - lower)) + lower
    }
}

extension NSURL {
    static func URLWithDelay(delay: Int) -> NSURL {
        return NSURL(string: "https://httpbin.org/delay/\(delay)")!
    }
}
