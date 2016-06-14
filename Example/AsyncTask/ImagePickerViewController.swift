//
//  ViewController.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 05/27/2016.
//  Copyright (c) 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask
import ReactiveUI
import Cartography

class ImagePickerDemoViewController: UIViewController {

    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .ScaleAspectFit
        view = imageView
        view.backgroundColor = UIColor.whiteColor()

        let barItem = UIBarButtonItem(title: "Launch Image Picker", style: .Plain, action: launchImagePicker)
        let flexiableSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)

        toolbarItems = [flexiableSpace, barItem, flexiableSpace]
        navigationController?.toolbarHidden = false
    }

    func launchImagePicker(button: UIBarButtonItem) {
        Task {
            let data = try! ImagePickerTask(viewController: self).await()
            if let image = data?[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageView.image = image
            } else {
                self.imageView.image = nil
            }
        }.async()
    }

}


