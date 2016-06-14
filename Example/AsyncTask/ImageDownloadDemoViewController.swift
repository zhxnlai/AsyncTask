//
//  DefaultDemoViewController.swift
//  AsyncDemo
//
//  Created by Zhixuan Lai on 2/25/16.
//  Copyright © 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class ImageDownloadDemoViewController: LogsTableViewController {

    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let width = tableView.frame.width
        let frame = CGRect(x: 0, y: 0, width: width, height: width)
        tableView.tableHeaderView = UIView(frame: frame)
        imageView.frame = frame
        imageView.contentMode = .ScaleAspectFit
        tableView.tableHeaderView?.addSubview(imageView)

        let downloadImage = Request(URL: NSURL(string: "https://httpbin.org/image/jpeg")!)

        let processImage = {(image: UIImage) in
            Task<UIImage> {
                let inputImage = CIImage(image: image)!

                let sepiaColor = CIColor(red: 0.76, green: 0.65, blue: 0.54)
                let monochromeFilter = CIFilter(name: "CIColorMonochrome",
                    withInputParameters: ["inputColor" : sepiaColor, "inputIntensity" : 1.0])!
                monochromeFilter.setValue(inputImage, forKey: "inputImage")

                let vignetteFilter = CIFilter(name: "CIVignette",
                    withInputParameters: ["inputRadius" : 1.75, "inputIntensity" : 1.0])!
                vignetteFilter.setValue(monochromeFilter.outputImage, forKey: "inputImage")
                
                let outputImage = vignetteFilter.outputImage!

                let ciContext = CIContext(options: nil)
                let cgImage = ciContext.createCGImage(outputImage, fromRect: inputImage.extent)

                return UIImage(CGImage: cgImage)
            }
        }

        let updateImageView = {(image: UIImage) in
            Task {
                self.imageView.image = image
            }
        }

        Task {[weak self] in
            self?.log("downloading image")
            var image = UIImage(data: downloadImage.await())!
            updateImageView(image).await(.Main)
            self?.log("processing image")
            image = processImage(image).await()
            updateImageView(image).await(.Main)
            self?.log("finished")
        }.async()
    }

}
