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
    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

}

extension ImagePickerTask : ThrowableTaskType {

    typealias ReturnType = [String : AnyObject]?
    func action(completion: Result<ReturnType> -> ()) {
        ThrowableTask<ReturnType> {
            try ThrowableTask {(callback: CompletionHandler) in
                guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
                    throw Error.PhotoLibraryNotAvailable
                }
                let controller = UIImagePickerController()
                controller.sourceType = .PhotoLibrary
                controller.delegate = self
                self.completionHandler = callback

                self.viewController.presentViewController(controller, animated: true, completion: nil)
            }.await(.Main)
        }.asyncResult(completion: completion)
    }

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

