# AsyncTask

[![CI Status](http://img.shields.io/travis/zhxnlai/AsyncTask.svg?style=flat)](https://travis-ci.org/zhxnlai/AsyncTask)
[![Version](https://img.shields.io/cocoapods/v/AsyncTask.svg?style=flat)](http://cocoapods.org/pods/AsyncTask)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/zhxnlai/AsyncTask)
[![License](https://img.shields.io/cocoapods/l/AsyncTask.svg?style=flat)](http://cocoapods.org/pods/AsyncTask)
[![Platform](https://img.shields.io/cocoapods/p/AsyncTask.svg?style=flat)](http://cocoapods.org/pods/AsyncTask)

An asynchronous programming library for Swift

## Features
AsyncTask is much more than Future and Promise.
- It is **composable**, allowing you to build complex workflow.
- It supports native **error handling** with `do-catch` and `try`.
- It is **protocol oriented**; so you can turn any object into a Task.

Without AsyncTask:
```swift
// get a global concurrent queue
let queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
// submit a task to the queue for background execution
dispatch_async(queue) {
    let enhancedImage = self.applyImageFilter(image) // expensive operation taking a few seconds
    // update UI on the main queue
    dispatch_async(dispatch_get_main_queue()) {
        self.imageView.image = enhancedImage
        UIView.animateWithDuration(0.3, animations: {
            self.imageView.alpha = 1
        }) { completed in
            // add code to happen next here
        }
    }
}
```

With AsyncTask:
```swift
Task {
    let enhancedImage = self.applyImageFilter(image)
    Task {self.imageView.image = enhancedImage}.async(.Main)
    let completed = UIView.animateWithDurationAsync(0.3) { self.label.alpha = 1 }.await(.Main)
    // add code to happen next here
}.async()
```

It even allows you to extend existing types:
```swift
let (data, response) = try! NSURL(string: "www.google.com")!.await()
```

## Installation

### [CocoaPods](http://cocoapods.org)
AsyncTask is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AsyncTask"
```

### [Carthage](https://github.com/Carthage/Carthage)

**Xcode 7.1 required**

Add this to `Cartfile`

```
github "zhxnlai/AsyncTask" ~> 0.1
```

```
$ carthage update
```

## Tutorial
* [Async Programming in Swift with AsyncTask](https://medium.com/@zhxnlai/async-programming-in-swift-with-asynctask-95a708c1c3c0)

## Usage
In AsyncTask, a `Task` represents the eventual result of an asynchronous operation, as do Future and Promise in other libraries. It can wrap both synchronous and asynchronous APIs. To create a `Task`, initialize it with a closure. To make it reusable, write functions that return a task.

```swift
// synchronous API
func encrypt(message: String) -> Task<String> {
    return Task {
        encrypt(message)
    }
}
// asynchronous API
func get(URL: NSURL) -> Task<(NSData?, NSURLResponse?, NSError?)> {
    return Task {completionHandler in
        NSURLSession().dataTaskWithURL(URL, completionHandler: completionHandler).resume()
    }
}
```

To get the result of a `Task`, use `async` or `await`. `async` is just like `dispatch_async`, and you can supply a completion handler. `await`, on the contrary, blocks the current thread and waits for the task to finish.

```swift
// async
encrypt(message).async { ciphertext in /* do somthing */ }
get(URL).async {(data, response, error) in /* do somthing */ }

// await
let ciphertext = encrypt(message).await()
let (data, response, error) = get(URL).await()
```

### Composing Tasks
You can use multiple await expressions to ensure that each statement completes before executing the next statement:

```swift
Task {
    print(“downloading image”)
    var image = UIImage(data: downloadImage.await())!
    updateImageView(image).await(.Main)
    print(“processing image”)
    image = processImage(image).await()
    updateImageView(image).await(.Main)
    print(“finished”)
}.async()
```

You can also call `awaitFirst` and `awaitAll` on a collection of tasks to execute them in parallel:

```swift
let replicatedURLs = ["https://web1.swift.org", "https://web2.swift.org"]
let first = replicatedURLs.map(get).awaitFirst()

let messages = ["1", "2", "3"]
let all = messages.map(encrypt).awaitAll()
```

### Handling Errors
Swift provide first-class support for [error handling](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html). In AsyncTask, a `ThrowableTask` takes a throwing closure and propagates the error.

```swift
func load(path: String) -> ThrowableTask<NSData> {
    return ThrowableTask {
        switch path {
        case "profile.png":
            return NSData()
        case "index.html":
            return NSData()
        default:
            throw Error.NotFound
        }
    }
}

expect{try load("profile.png").await()}.notTo(throwError())
expect{try load("index.html").await()}.notTo(throwError())
expect{try load("random.txt").await()}.to(throwError())
```

### Extending Tasks
AsyncTask is [protocol oriented](https://developer.apple.com/videos/play/wwdc2015/408/); it defines `TaskType` and `ThrowableTaskType` and provides the default implementation of `async` and `await` using protocol extension. In other words, these protocols are easy to implement, and you can `await` on any object that confronts to them. Being able to extend tasks powerful because it allows tasks to encapsulate states and behaviors.

In the following example, by extending `NSURL` to be `TaskType`, we make data fetching a part of the NSURL class. To confront to the `TaskType` protocol, just specify an action and the return type.

```swift
extension NSURL : ThrowableTaskType {

    public typealias ReturnType = (NSData, NSURLResponse)

    public func action(completion: Result<ReturnType> -> ()) {
        ThrowableTask<ReturnType> {
            let session = NSURLSession(configuration: .ephemeralSessionConfiguration())
            let (data, response, error) = Task { callback in session.dataTaskWithURL(self, completionHandler: callback).resume()}.await()
            guard error == nil else { throw error! }
            return (data!, response!)
        }.asyncResult(completion: completion)
    }

}
```

This extension allows us to write the following code:

```swift
let (data, response) = try! NSURL(string: "www.google.com")!.await()
```

A Task can represent more complicated activities, even those involving UI. In the following example, we use an `ImagePickerTask` to launch a `UIImagePickerViewController` and wait for the user to choose an image. Once the user selects an image or press the cancel button, the view controller dismisses, and the task returns with the selected image.


```swift
class ImagePickerDemoViewController: UIViewController {

    let imageView = UIImageView()

    func launchImagePicker() {
        Task {
            do {
                let data = try ImagePickerTask(viewController: self).await()
            } catch Error.PhotoLibraryNotAvailable {
                alert("Photo Library is Not Available")
            }
            guard let image = data?[UIImagePickerControllerOriginalImage] as? UIImage else {
                self.imageView.image = nil
                return
            }
            self.imageView.image = image
        }.async()
    }

}
```
The `ImagePickerTask` knows when the user has picked an image or canceled because it is the `UIImagePickerViewController`’s delegate. For more details, see its [implementation](https://gist.github.com/zhxnlai/7594df6ec62daf3d38ada9593c9b7408) and the example folder.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

You may also want to take a look at the [test cases](https://github.com/zhxnlai/AsyncTask/tree/master/Example/Tests).

## Author

Zhixuan Lai, zhxnlai@gmail.com

## License

AsyncTask is available under the MIT license. See the LICENSE file for more info.
