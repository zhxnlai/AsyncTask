//
//  DefaultDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/25/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask
import ReactiveUI

class LogsTableViewController: UITableViewController {

    var logs = [String]()
    let dateFormatter = NSDateFormatter()

    override init(style: UITableViewStyle) {
        super.init(style: style)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func setup() {
        dateFormatter.dateFormat = "HH:mm:ss"
    }

    func log(message: String) {
        let message = "\(dateFormatter.stringFromDate(NSDate())) \(message)"
        logs.append(message)
        print(message)
        Task {
            self.tableView.reloadData()
        }.async(.Main)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        cell.textLabel?.text = logs[indexPath.row]
        return cell
    }

}
