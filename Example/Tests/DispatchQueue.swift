import Quick
import Nimble
import AsyncTask

class DispatchQueueSpec: QuickSpec {
    override func spec() {
        // Thanks to https://github.com/duemunk/Async
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
                }.async(.UserInteractive)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_USER_INITIATED
                }.async(.UserInitiated)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_UTILITY
                }.async(.Utility)

            Task() {
                expect(qos_class_self()) == QOS_CLASS_BACKGROUND
                }.async(.Background)

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
}
