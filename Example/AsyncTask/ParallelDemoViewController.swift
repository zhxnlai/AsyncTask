//
//  ParallelDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/24/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class ParallelRequestDemoViewController {

//    override func reload() {
//        requests.removeAll()
//        for _ in 0..<numberOfRequests {
//            let delay = random() % 10
//            requests.append(DelayedRequest(delay: delay))
//        }
//
//        Task {[weak self] in
//            let results = self!.requests.enumerate().map {(index: Int, request: DelayedRequest) in
//                Task { () -> NSData in
//                    self?.updateRequest(index, state: .Running)
//
//                    let data = get(request.URL).await()
//
//                    self?.updateRequest(index, state: .Finished)
//                    print("downloaded URL: \(request.URL)")
//                    return data
//                }
//            }.awaitAll()
//
//            print("downloaded \(results.count) URLs in parallel")
//        }.async()
//
//    }

}
