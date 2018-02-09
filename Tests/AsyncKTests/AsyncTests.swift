import XCTest
import Dispatch
@testable import AsyncK

class AsyncTests: XCTestCase {
    func testExample() {
        /**/ let expectation = self.expectation(description: "testExample")
        /**/ var result: Int!
        
        // func foo() async -> Int {
        //     return suspendAsync { continuation in
        //         // ...
        //     }
        // }
        //
        // func bar(_ x: Int) async -> Int {
        //     // ...
        // }
        //
        // beginAsync {
        //     let a = await foo()
        //     let b = await bar(a)
        //     print(b)
        // }
        
        func foo() -> Async<Int> {
            return suspendAsync { continuation in
                // ...
                /**/ DispatchQueue.main.async {
                /**/     continuation(42)
                /**/ }
            }
        }
        
        func bar(_ x: Int) -> Async<Int> {
            // ...
            /**/ return suspendAsync { continuation in
            /**/     DispatchQueue.main.async {
            /**/         continuation(x * x)
            /**/     }
            /**/ }
        }
        
        beginAsync {
            foo().await { a in
                bar(a)
            }.await { b -> Void in
                print(b)
                /**/ result = b
                /**/ expectation.fulfill()
            }
        }
        
        /**/ waitForExpectations(timeout: 1.0, handler: nil)
        
        /**/ XCTAssertEqual(result, 42 * 42)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

extension Async {
    func wait() {
        var finished = false
        _ = self.await { (value: Value) -> Async<()> in
            finished = true
            return Async<()>(())
        }
        while (!finished){
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
    
    func sync() -> Value {
        wait()
        var value: Value? = nil
        _ = await {
            value = $0
        }
        return value!
    }
}
