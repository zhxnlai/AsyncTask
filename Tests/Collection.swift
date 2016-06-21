import Quick
import Nimble
import AsyncTask

class CollectionSpec: QuickSpec {
    override func spec() {
        describe("array of tasks") {
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

            it("should in parallel") {
                for _ in 0..<1000 {
                    let results = numbers.map(toString).awaitAll()
                    expect(results).to(contain("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"))
                }
            }

            it("should in parallel") {
                for _ in 0..<10 {
                    let results = (0..<500).map({n in toStringAfter(n, timeoutInterval: 0.0001)}).awaitAll()
                    expect(results.count) == 500
                }
            }

            it("should in parallel") {
                let results = (0..<5000).map({n in toStringAfter(n, timeoutInterval: 0.0001)}).awaitAll()
                expect(results.count) == 5000
            }
        }

        describe("dictionary of tasks") {
            it("should run a dictionary of closures in parallel") {
                var tasks = [Int: Task<String>]()
                for (index, element) in numbers.map(toString).enumerate() {
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
        }

        describe("array of tasks") {
            it("can await first") {
                let result = numbers.shuffle().map {number in toStringAfter(number, timeoutInterval: NSTimeInterval(number + 1))}.awaitFirst()
                expect(result) == "0"
            }

            it("can await first") {
                let task1 = Task<String?> {
                    timeout(2).await()
                    return "aa"
                }

                let task2 = Task<String?> {
                    timeout(1).await()
                    return nil
                }

                expect{[task1, task2].awaitFirst()}.to(beNil())
            }
        }

        describe("array of throwing tasks") {
            it("should throw if any task throws") {
                expect{try numbers.map(toStringExceptZero).awaitAll()}.to(throwError())
            }
        }
    }
}


let numbers: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

func toString(number: Int) -> Task<String> {
    return Task { "\(number)" }
}

func timeout(timeout: NSTimeInterval) -> Task<Void> {
    return Task { NSThread.sleepForTimeInterval(timeout) }
}

func toStringAfter(number: Int, timeoutInterval: NSTimeInterval) -> Task<String> {
    return Task {
        timeout(timeoutInterval).await()
        return toString(number).await()
    }
}

enum Error : ErrorType {
    case FoundZero
}

let toStringExceptZero = {(number: Int) -> ThrowableTask<String> in
    ThrowableTask {
        if number == 0 {
            throw Error.FoundZero
        }
        return "\(number)"
    }
}


