// https://github.com/Quick/Quick

import Quick
import Nimble
import AsyncTask

class TableOfContentsSpec: QuickSpec {
    override func spec() {

        // wrap expensive sync api
        describe("task") {

            it("can warp expensive synchronous API") {
                func encode(message: String) -> String {
                    NSThread.sleepForTimeInterval(0.1)
                    return message
                }

                let encryptMessage = {(message: String) in
                    Task {
                        encode(message)
                    }
                }

                let message = "Hello"
                let encrypted = encryptMessage(message).await()
                expect(encrypted) == message
            }

            it("can wrap asynchronous APIs") {
                let session = NSURLSession(configuration: .ephemeralSessionConfiguration())

                let get = {(URL: NSURL) in
                    Task {callback in
                        session.dataTaskWithURL(URL, completionHandler: callback).resume()
                    }
                }

                let URL = NSURL(string: "https://httpbin.org/delay/1")!
                let (data, response, error) = get(URL).await()
                expect(data).to(beTruthy())
                expect(response).to(beTruthy())
                expect(response!.URL!.absoluteString) == "https://httpbin.org/delay/1"
                expect(error).to(beNil())
            }

        }

        // wrap async api

        describe("await") {

            it("should return nil if timeout occurs") {
                let task = Task { () -> Bool in NSThread.sleepForTimeInterval(0.3); return true }
                expect(task.await(timeout: 0.4)) == true
                expect(task.await(timeout: 0.2)).to(beNil())
            }

        }

        describe("concurrency") {
            let numbers: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

            it("should return nil if timeout occurs") {
                let printNumber = {(number: Int) in
                    Task {
                        NSThread.sleepForTimeInterval(1)
                        print(number)
                    }
                }

                numbers.map(printNumber).await()
            }

        }

        describe("collection") {

            enum Error : ErrorType {
                case FoundZero
            }

            let numbers: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            let toString = {(number: Int) in
                Task {() -> String in
                    return "\(number)"
                }
            }

            let toStringExceptZero = {(number: Int) in
                ThrowingTask {() -> String in
                    if number == 0 {
                        throw Error.FoundZero
                    }
                    return "\(number)"
                }
            }

            it("should run serially inside for loops") {
                var results = [String]()
                for number in numbers {
                    results.append(toString(number).await())
                }
                expect(results) == numbers.map {number in "\(number)"}
            }

            it("should run serially inside map") {
                let results = numbers.map {number in toString(number).await()}
                expect(results) == numbers.map {number in "\(number)"}
            }

            it("should run an array of closures in parallel") {
                let results = numbers.map(toString).await()

                expect(results).to(contain("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"))
            }

            it("should run a dictionary of closures in parallel") {
                var tasks = [Int: Task<String>]()
                let re = numbers.map(toString)
                for (index, element) in re.enumerate() {
                    let key = numbers[index]
                    tasks[key] = element
                }
                let results = tasks.await()

                var expected = [Int: String]()
                for number in numbers {
                    expected[number] = "\(number)"
                }
                expect(results.count) == expected.count
                for (key, _) in expected {
                    expect(expected[key]) == results[key]
                }
            }

            it("should throw if one of the task throws") {
                expect{try numbers.map(toStringExceptZero).await()}.to(throwError())
            }

        }

        describe("async and await") {
            it("can be chained together") {
                let emptyString = Task {() -> String in
                    NSThread.sleepForTimeInterval(0.05)
                    return ""
                }

                let appendString = {(a: String, b: String) in
                    Task {() -> String in
                        NSThread.sleepForTimeInterval(0.05)
                        return a + b
                    }
                }

                let chainedTask = Task {(completion: String -> ()) in
                    emptyString.async {(s: String) in
                        expect(s) == ""
                        appendString(s, "https://").async {(s: String) in
                            expect(s) == "https://"
                            appendString(s, "swift").async {(s: String) in
                                expect(s) == "https://swift"
                                appendString(s, ".org").async {(s: String) in
                                    expect(s) == "https://swift.org"
                                    completion(s)
                                }
                            }
                        }
                    }
                }

                let sequentialTask = Task {() -> String in
                    var s = emptyString.await()
                    expect(s) == ""
                    s = appendString(s, "https://").await()
                    expect(s) == "https://"
                    s = appendString(s, "swift").await()
                    expect(s) == "https://swift"
                    s = appendString(s, ".org").await()
                    expect(s) == "https://swift.org"
                    return s
                }

                expect(sequentialTask.await()) == chainedTask.await()
            }

        }

        // optional
        describe("optional") {
            it("can take optional") {
                let load = {(path: String) in
                    Task {() -> NSData? in
                        NSThread.sleepForTimeInterval(0.05)
                        switch path {
                        case "profile.png":
                            return NSData()
                        case "index.html":
                            return NSData()
                        default:
                            return nil
                        }
                    }
                }

                let data1 = load("profile.png").await()
                expect(data1).to(beTruthy())

                let data2 = load("index.html").await()
                expect(data2).to(beTruthy())

                let data3 = load("random.txt").await()
                expect(data3).to(beNil())
            }
            
        }

        describe("throwable") {
            it("can take throwable") {
                enum Error: ErrorType {
                    case NotFoundError
                }

                let load = {(path: String) in
                    ThrowingTask {() throws -> NSData in
                        NSThread.sleepForTimeInterval(0.05)
                        switch path {
                        case "profile.png":
                            return NSData()
                        case "index.html":
                            return NSData()
                        default:
                            throw Error.NotFoundError
                        }
                    }
                }

                expect{try load("profile.png").await()}.notTo(throwError())
                expect{try load("index.html").await()}.notTo(throwError())
                expect{try load("random.txt").await()}.to(throwError())
            }

        }

        // TODO: test performace against GCD APIs

        // Thanks to https://github.com/duemunk/Async
        describe("DispatchQueue") {
            it("works with async") {

                // waiting on the current thread creates dead lock
                Task() {
                    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS)) // Simulator
                        expect(NSThread.isMainThread()) == true
                    #else
                        expect(qos_class_self()) == qos_class_main()
                    #endif
                }.async(.Main)

                Task() {
                    expect(qos_class_self()) == QOS_CLASS_USER_INTERACTIVE
                }.await(.UserInteractive)

                Task() {
                    expect(qos_class_self()) == QOS_CLASS_USER_INITIATED
                }.await(.UserInitiated)

                Task() {
                    expect(qos_class_self()) == QOS_CLASS_UTILITY
                }.await(.Utility)

                Task() {
                    expect(qos_class_self()) == QOS_CLASS_BACKGROUND
                }.await(.Background)

                let customQueue = dispatch_queue_create("CustomQueueLabel", DISPATCH_QUEUE_CONCURRENT)
                Task() {
                    let currentClass = qos_class_self()
                    let isValidClass = currentClass == qos_class_main() || currentClass == QOS_CLASS_USER_INITIATED
                    expect(isValidClass) == true
                    // TODO: Test for current queue label. dispatch_get_current_queue is unavailable in Swift, so we cant' use the return value from and pass it to dispatch_queue_get_label.
                }.await(.Custom(customQueue))

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.05)
                    done()
                }
            }
        }

        describe("Additional") {
            it("should execute asynchronously") {
                var a = 0

                Task {
                    NSThread.sleepForTimeInterval(0.05)
                    expect(a) == 0
                    a = 1
                    expect(a) == 1
                    }.async { expect(a) == 1 }

                expect(a) == 0
                expect(a).toEventually(equal(1), timeout: 3)

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }

            it("should return result in callback") {
                let echo = Task {() -> String in
                    NSThread.sleepForTimeInterval(0.05)
                    return "Hello"
                }

                echo.async {(message: String) in
                    expect(message) == "Hello"
                }

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }

            it("can wait synchronously") {
                var a = 0

                Task { NSThread.sleepForTimeInterval(0.05); expect(a) == 1 }.async()
                Task {expect(a) == 0}.await()

                a = 1

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }
                
        }

    }
}
