//
//  RequestTasks.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 6/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AsyncTask

class RequestsTask: NSObject {

    enum Option {
        case Serial, Parallel
    }

    private var task: Task<ReturnType>!
    let requests: [Request]
    let option: Option
    private(set) var running = false

    init(requests: [Request], option: Option) {
        self.requests = requests
        self.option = option
        super.init()
        task = Task<[NSData]> {[unowned self] in
            self.running = true
            var results : [NSData]!
            switch option {
            case .Serial:
                results = self.requests.map {request in request.await()}
            case .Parallel:
                results = self.requests.awaitAll()
            }
            self.running = false
            return results
        }
    }

}

extension RequestsTask : TaskType {

    typealias ReturnType = [NSData]
    typealias ActionType = (Result<ReturnType> -> ()) -> ()
    var action: ActionType { get {return task.action} }

}

extension RequestsTask : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }

        let request = requests[indexPath.row]
        cell.textLabel?.text = "State: \(request.state.description)"
        cell.accessoryType = .None
        cell.accessoryView = nil
        switch request.state {
        case .Pending:
            break
        case .Running:
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            spinner.startAnimating()
            cell.accessoryView = spinner
        case .Finished:
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
}
