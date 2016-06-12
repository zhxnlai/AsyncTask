//
//  DefaultDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/25/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class DefaultDemoViewController: LogsTableViewController {

    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let createImage = Task {() -> UIImage in
            sleep(3)
            return UIImage()
        }

        let processImage = {(image: UIImage) in
            Task {() -> UIImage in
                sleep(1)
                return image
            }
        }

        let updateImageView = {(image: UIImage) in
            Task {
                self.imageView.image = image
            }
        }

        Task {[weak self] in
            self?.log("creating image")
            var image = createImage.await()
            self?.log("processing image")
            image = processImage(image).await()
            Task { self?.imageView.image = UIImage() }.async(.Main)
            self?.log("updating imageView")
            updateImageView(image).await(.Main)
            self?.log("updated imageView")
        }.async()
    }

}
