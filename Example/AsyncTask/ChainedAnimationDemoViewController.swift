//
//  ChainedAnimationDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/25/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class ChainedAnimationDemoViewController: UIViewController {

    let label = UILabel(frame: CGRectMake(0, 0, 200, 21))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        label.center = randomCenter()
        label.textAlignment = NSTextAlignment.Center
        label.text = "Test Label"
        view.addSubview(label)

        let duration: NSTimeInterval = 1

        Task {[weak self] in
            while self != nil {
                let completed = Task<Bool> {callback in
                    UIView.animateWithDuration(duration, animations: { self?.label.center = self!.randomCenter() }, completion: callback)
                }.await(.Main)
                print("animation completed: \(completed)")
            }
        }.async()
    }

    func randomCenter() -> CGPoint {
        return CGPointMake(CGFloat.random(0.2, upper: 0.8) * view.frame.width, CGFloat.random(0.2, upper: 0.8) * view.frame.height)
    }

}
