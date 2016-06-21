// https://github.com/Quick/Quick

import Quick
import Nimble

import AsyncTask

class TaskSpec: QuickSpec {
    override func spec() {
        
        it("can warp expensive synchronous API") {
            func encode(message: String) -> String {
                NSThread.sleepForTimeInterval(0.1)
                return message
            }

            func encryptMessage(message: String) -> Task<String> {
                return Task {
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
                Task { session.dataTaskWithURL(URL, completionHandler: $0).resume() }
            }

            let URL = NSURL(string: "https://httpbin.org/delay/1")!
            let (data, response, error) = get(URL).await()
            expect(data).to(beTruthy())
            expect(response).to(beTruthy())
            expect(response!.URL!.absoluteString) == "https://httpbin.org/delay/1"
            expect(error).to(beNil())
        }
    }
}
