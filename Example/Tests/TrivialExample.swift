import Quick
import Nimble
import AsyncTask

class TrivialExampleSpec: QuickSpec {
    override func spec() {
        describe("task") {
            it("can take optional value") {
                let load = {(path: String) -> Task<NSData?> in
                    Task {
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

                expect(load("profile.png").await()).to(beTruthy())
                expect(load("index.html").await()).to(beTruthy())
                expect(load("random.txt").await()).to(beNil())
            }

            it("can be nested") {
                let emptyString = Task<String> {
                    NSThread.sleepForTimeInterval(0.05)
                    return ""
                }

                let appendString = {(a: String, b: String) -> Task<String> in
                    Task {
                        NSThread.sleepForTimeInterval(0.05)
                        return a + b
                    }
                }

                let chainedTask = Task<String> {completion in
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

                let sequentialTask = Task<String> {
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
