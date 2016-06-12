//
//  ViewController.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 05/27/2016.
//  Copyright (c) 2016 Zhixuan Lai. All rights reserved.
//

import UIKit
import AsyncTask

class ImagePickerDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        Task {
            print(self.chooseFromLibrary().await())
            print("finished")
        }.async()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIViewController {
    
    func chooseFromLibrary() -> Task<[String : AnyObject]?> {
        typealias CompletionHandler = [String: AnyObject]? -> ()

        class Delegate : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            var task: CompletionHandler!

            @objc func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
                task(info)
                picker.dismissViewControllerAnimated(true, completion: nil)
            }

            @objc func imagePickerControllerDidCancel(picker: UIImagePickerController) {
                task(nil)
                picker.dismissViewControllerAnimated(true, completion: nil)
            }
        }

        let delegate = Delegate()

        return Task {
            Task {(callback: CompletionHandler) in
                let controller = UIImagePickerController()
                controller.sourceType = .PhotoLibrary
                controller.delegate = delegate
                delegate.task = callback

                self.presentViewController(controller, animated: true, completion: nil)
            }.await(.Main)
        }
    }

    func presentViewControllerTask(viewControllerToPresent: UIViewController, animated: Bool) {

    }

}

