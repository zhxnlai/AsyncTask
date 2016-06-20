//
//  SerialDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/24/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask
import ReactiveUI

class RequestDemoViewController : UITableViewController {

    var segmentedControl: UISegmentedControl!
    var serialRequestsTask: RequestsTask!
    var parallelRequestsTask: RequestsTask!

    var currentRequestTask: RequestsTask!

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl = UISegmentedControl(items: ["Serial", "Parallel"])
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.forControlEvents(.ValueChanged) {_ in
            self.updateViews()
        }
        navigationItem.titleView = segmentedControl

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh) {_ in
            self.currentRequestTask.async()
            self.updateViews()
        }

        serialRequestsTask = RequestsTask(requests: randomDelayedRequests(10), option: .Serial)
        parallelRequestsTask = RequestsTask(requests: randomDelayedRequests(10), option: .Parallel)

        updateViews()
    }

    func randomDelayedRequests(numberOfRequests: Int) -> [Request] {
        var requests = [Request]()
        for _ in 0..<numberOfRequests {
            let delay = random() % 5
            let URL = NSURL.URLWithDelay(delay)
            let request = Request(URL: URL)
            request.didChange = updateViews
            requests.append(request)
        }
        return requests
    }

    func updateViews() {
        Task {
            self.update()
        }.async(.Main)
    }

    func update() {
        if segmentedControl.selectedSegmentIndex == 0 {
            currentRequestTask = serialRequestsTask
        } else {
            currentRequestTask = parallelRequestsTask
        }
        tableView.dataSource = currentRequestTask
        tableView.reloadData()

        navigationItem.rightBarButtonItem?.enabled = !currentRequestTask.running
    }

}



