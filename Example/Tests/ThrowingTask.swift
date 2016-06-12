import Quick
import Nimble
import AsyncTask

class ThrowingTaskSpec: QuickSpec {
    override func spec() {
        it("should throw") {
            enum Error: ErrorType {
                case NotFound
            }

            let load = {(path: String) -> ThrowingTask<NSData> in
                ThrowingTask {
                    NSThread.sleepForTimeInterval(0.05)
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
            expect{try [load("profile.png"), load("index.html")].awaitAll()}.notTo(throwError())
            expect{try [load("profile.png"), load("index.html"), load("random.txt")].awaitAll()}.to(throwError())
        }
    }
}
