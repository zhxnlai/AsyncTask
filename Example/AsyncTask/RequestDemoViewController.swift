//
//  SerialDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/24/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class RequestDemoViewController : UIViewController {

//    var delayedRequestLoader = DelayedRequestLoader()

    override func viewDidLoad() {
        super.viewDidLoad()


    }


//    override func reload() {
//        requests.removeAll()
//        for _ in 0..<numberOfRequests {
//            let delay = random() % 10
//            requests.append(DelayedRequest(delay: delay))
//        }
//
//    }
}


//class Request : TaskType {
//
//    enum State {
//        case Pending, Running, Finished(NSData)
//
//        var description : String {
//            switch self {
//            case .Pending: return "Pending";
//            case .Running: return "Running";
//            case .Finished: return "Finished";
//            }
//        }
//    }
//
//    let URL: NSURL
//    private(set) var state: State = .Pending
//
//    typealias ReturnType = NSData
//
//    var baseTask: BaseTask<NSData> {
//        get {
//            return task.baseTask
//        }
//    }
//
//    var action: (Result<NSData> -> ()) -> () {
//        get {
//            return baseTask.action
//        }
//    }
//
//
//
//    let task: Task<NSData>
//
//    init(URL aURL: NSURL) {
//        URL = aURL
//        task = Task<NSData> {
//            self.state = .Running
//            let data = get(self.URL).await()
//            self.state = .Finished(data)
//            return data
//        }
//    }
//
////    mutating func task() -> Task<NSData> {
////        return Task {
////            self.state = .Running
////            let data = get(self.URL).await()
////            self.state = .Finished(data)
////            return data
////        }
////    }
//
//}

extension NSURL {

    static func URLWithDelay(delay: Int) -> NSURL {
        return NSURL(string: "https://httpbin.org/delay/\(delay)")!
    }

}

//class DelayedRequestLoader: NSObject {
//    enum Option {
//        case Serial, Parallel
//    }
//
//    var option = Option.Serial {
//        didSet {
//
//        }
//    }
//
//    var requests = [Request]()
//    var didChange = {}
//
//    func reload() {
//        Task {[weak self] in
//            var results = [NSData]()
//
////            requests.
//
//            for (index, request) in self!.requests.enumerate() {
//                guard self != nil else { break }
//
//                self?.updateRequest(index, state: .Running)
//
//                let data = get(request.URL).await()
//
//                self?.updateRequest(index, state: .Finished)
//                results.append(data)
//
//                print("downloaded URL: \(request.URL)")
//            }
//
//            print("downloaded \(results.count) URLs in series")
//            }.async()
//    }
//
//    func updateRequest(index: Int, state: DelayedRequest.State) {
//        Task {[unowned self] in
//            self.requests[index].state = state
//            self.didChange()
//        }.async(.Main)
//    }
//
//}
//
//extension DelayedRequestLoader : UITableViewDataSource {
//
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return requests.count
//    }
//
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cellIdentifier = String(format: "s%li-r%li", indexPath.section, indexPath.row)
//        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
//        if cell == nil {
//            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
//        }
//
//        let request = requests[indexPath.row]
//        cell.textLabel?.text = "Delay: \(request.delay)   State: \(request.state.description)"
//        switch request.state {
//        case .Pending:
//            cell.accessoryView = nil
//        case .Running:
//            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
//            spinner.startAnimating()
//            cell.accessoryView = spinner
//        case .Finished:
//            cell.accessoryView = nil
//            cell.accessoryType = .Checkmark
//        }
//        
//        return cell
//    }
//    
//}

/*
 struct RequestTask: TaskType {
 // original IntStack implementation
 var items = [Int]()
 mutating func push(item: Int) {
 items.append(item)
 }
 mutating func pop() -> Int {
 return items.removeLast()
 }
 // conformance to the Container protocol
 typealias ItemType = Int
 mutating func append(item: Int) {
 self.push(item)
 }
 var count: Int {
 return items.count
 }
 subscript(i: Int) -> Int {
 return items[i]
 }
 }

 */