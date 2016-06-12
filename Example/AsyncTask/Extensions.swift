//
//  Extensions.swift
//  Async
//
//  Created by Zhixuan Lai on 3/2/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AsyncTask

extension UIView {
    class func animateWithDuration(duration: NSTimeInterval, animations: () -> Void) -> Task<Bool> {
        return thunkify(UIView.animateWithDuration)(duration, animations)
    }
}

