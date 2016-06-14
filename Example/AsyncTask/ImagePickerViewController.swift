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
    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(imageView)

        button.setTitle("Pick an image", forState: .Normal)
        button.forControlEvents(.TouchUpInside, addAction: buttonTouchUpInside)
        view.addSubview(button)

//        let button = UIButton()
//        button.titleLabel =


    }


    func buttonTouchUpInside(button: UIControl) {
        Task {
            let data = ImagePickerTask(viewController: self).await()
        }.async()
    }

}


