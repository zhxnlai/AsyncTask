// https://github.com/Quick/Quick

import Quick
import Nimble
import AsyncTask

class TableOfContentsSpec: QuickSpec {
    override func spec() {

        describe("these will fail") {
//
//            it("can do maths") {
//                expect(1) == 2
//            }
//
//            it("can read") {
//                expect("number") == "string"
//            }
//
//            it("will eventually fail") {
//                expect("time").toEventually( equal("done") )
//            }
//            
            context("these will pass") {

                it("can do maths") {
                    expect(23) == 23
                    print("here")
                }

                it("can read") {
                    expect("🐮") == "🐮"
                }

                it("will eventually pass") {
                    var time = "passing"

                    dispatch_async(dispatch_get_main_queue()) {
                        time = "done"
                    }

                    waitUntil { done in
                        NSThread.sleepForTimeInterval(0.5)
                        expect(time) == "done"

                        done()
                    }
                }
            }
        }

        describe("AsyncTask") {
            it("should execute asynchronously") {
                var a = 0

                AsyncTask {
                    NSThread.sleepForTimeInterval(0.05)
                    expect(a) == 0
                    a = 1
                    expect(a) == 1
                }.start { expect(a) == 1 }

                expect(a) == 0
                expect(a).toEventually(equal(1), timeout: 3)

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }

            it("should return result in callback") {
                let echo = AsyncTask {() -> String in
                    NSThread.sleepForTimeInterval(0.05)
                    return "Hello"
                }

                echo.start {(message: String) in
                    expect(message) == "Hello"
                }

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }
        }
        
        describe("await") {

            it("can wait synchronously") {

                var a = 0

                AsyncTask {expect(a) == 0}.wait()
                AsyncTask {
                    NSThread.sleepForTimeInterval(0.05)
                    expect(a) == 1
                }.start()

                a = 1

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }

            it("can take async or a closure that returns async") {
                AsyncTask {
                    AsyncTask {expect(1) == 1}.wait()
                }.start()

                waitUntil { done in
                    NSThread.sleepForTimeInterval(0.5)
                    done()
                }
            }

//            it("should return nil if timeout occurs") {
//                async {
//                    await(timeout: 0.4) { async { () -> Bool in NSThread.sleepForTimeInterval(0.3); return true } }
//                    }() {value in expect(value) == true }
//
//                async {
//                    await(timeout: 0.2) { async { () -> Bool in NSThread.sleepForTimeInterval(0.3); return true } }
//                    }() {value in expect(value).to(beNil())}
//
//                waitUntil { done in
//                    NSThread.sleepForTimeInterval(0.5)
//                    done()
//                }
//            }
//
            it("can wrap asynchronous APIs") {
                let session = NSURLSession(configuration: .ephemeralSessionConfiguration())

                let get = {(URL: NSURL) in
                    AsyncTask {callback in
                        session.dataTaskWithURL(URL, completionHandler: callback).resume()
                    }
                }

                AsyncTask {
                    let URL = NSURL(string: "https://httpbin.org/delay/1")!
                    let (data, response, error) = get(URL).wait()
                    expect(data).to(beTruthy())
                    expect(response).to(beTruthy())
                    expect(response!.URL!.absoluteString) == "https://httpbin.org/delay/1"
                    expect(error).to(beNil())
                }.start()

                waitUntil(timeout: 3) { done in
                    NSThread.sleepForTimeInterval(1.5)
                    done()
                }
            }

            it("can wrap asynchronous APIs2") {
                let session = NSURLSession(configuration: .ephemeralSessionConfiguration())

                let get = {(URL: NSURL) in
                    AsyncTask {callback in
                        session.dataTaskWithURL(URL, completionHandler: callback).resume()
                    }
                }

                AsyncTask {
                    let URL = NSURL(string: "https://httpbin.org/delay/1")!
                    let (data, response, error) = get(URL).wait()
                    expect(data).to(beTruthy())
                    expect(response).to(beTruthy())
                    expect(response!.URL!.absoluteString) == "https://httpbin.org/delay/1"
                    expect(error).to(beNil())
                    print("haha")
                }.wait()

//                waitUntil(timeout: 3) { done in
//                    NSThread.sleepForTimeInterval(1.5)
//                    done()
//                }
            }

//
//            it("should run serially inside for loops") {
//                let numbers: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
//                let toString = {(number: Int) in
//                    async {() -> String in
//                        return "\(number)"
//                    }
//                }
//
//                async {
//                    var results = [String]()
//                    for number in numbers {
//                        let numberString = await { toString(number) }
//                        results.append(numberString)
//                    }
//                    return results
//                    }() {(results: [String]) in expect(results) == numbers.map {number in "\(number)"}}
//
//                waitUntil { done in
//                    NSThread.sleepForTimeInterval(0.5)
//                    done()
//                }
//            }
//
//            it("should run an array of closures in parallel") {
//                let numbers: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
//                let toString = {(number: Int) in
//                    async {() -> String in
//                        NSThread.sleepForTimeInterval(0.03)
//                        return "\(number)"
//                    }
//                }
//
//                async {
//                    await(parallel: numbers.map(toString))
//                    }() {(results:[String]) in expect(results).to(contain("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"))}
//
//                waitUntil { done in
//                    NSThread.sleepForTimeInterval(0.5)
//                    done()
//                }
//            }
//
//            it("should run a dictionary of closures in parallel") {
//                let numbers: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
//                let toString = {(number: Int) in
//                    async {() -> String in
//                        NSThread.sleepForTimeInterval(0.03)
//                        return "\(number)"
//                    }
//                }
//
//                async {
//                    var object: [Int: (String -> Void) -> Void] = [:]
//                    let tasks = numbers.map(toString)
//                    for (index, element) in tasks.enumerate() {
//                        let key = numbers[index]
//                        object[key] = element
//                    }
//                    return await(parallel: object)
//                    }() {(results:[Int: String]) in
//                        var expected = [Int: String]()
//                        for number in numbers {
//                            expected[number] = "\(number)"
//                        }
//                        expect(results.count) == expected.count
//                        for (key, _) in expected {
//                            expect(expected[key]) == results[key]
//                        }
//                }
//                
//                waitUntil { done in
//                    NSThread.sleepForTimeInterval(0.5)
//                    done()
//                }
//            }
        }

    }
}
