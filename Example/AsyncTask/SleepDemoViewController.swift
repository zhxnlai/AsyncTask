//
//  SleepDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/25/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class SleepDemoViewController: LogsTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {[weak self] in
            while self != nil {
                let seconds = UInt32(random() % 5)

                self?.log("will sleep for \(seconds) sec")
                sleep(seconds)
            }
        }.async()
    }

}
