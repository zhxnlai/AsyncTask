//
//  ImagePickerTask.swift
//  AsyncTask
//
//  Created by Zhixuan Lai on 6/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AsyncTask

class ImagePickerTask : NSObject {
    enum Error : ErrorType {
        case PhotoLibraryNotAvailable
    }

    typealias CompletionHandler = [String: AnyObject]? -> ()
    var completionHandler: CompletionHandler!
    var task: ThrowableTask<ReturnType>!

    init(viewController: UIViewController) {
        super.init()
        task = ThrowableTask<ReturnType> {
            try ThrowableTask {(callback: CompletionHandler) in
                guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
                    throw Error.PhotoLibraryNotAvailable
                }
                let controller = UIImagePickerController()



                controller.sourceType = .PhotoLibrary
                controller.delegate = self
                self.completionHandler = callback

                viewController.presentViewController(controller, animated: true, completion: nil)
            }.await(.Main)
        }
    }

}

extension ImagePickerTask : TaskType {

    typealias ReturnType = [String : AnyObject]?
    typealias ActionType = (Result<ReturnType> -> ()) -> ()
    var action: ActionType { get {return task.action} }

}

extension ImagePickerTask : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        completionHandler(info)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @objc func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        completionHandler(nil)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

