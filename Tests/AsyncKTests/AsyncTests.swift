import XCTest
import Dispatch
@testable import AsyncK

class AsyncTests: XCTestCase {
    func testAsyncWhile() {
        let expectation = self.expectation(description: "testAsyncWhile")
        
        var result: [Int] = []
        
        beginAsync {
            var count = 1
            
            return asyncWhile(count <= 100) {
                foo(count).await { value -> Void in
                    result.append(value)
                    count += 1
                }
            }.await {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssertEqual(result, [Int](1...100))
    }
    
    func testAsyncWhileBreak() {
        let expectation = self.expectation(description: "testAsyncWhileBreak")
        
        var result: [Int] = []
        
        beginAsync {
            var count = 1
            
            return asyncWhile(count <= 100) { `break` in
                foo(count).await { value -> Void in
                    if count == 20 {
                        `break`()
                        return
                    }
                    result.append(value)
                    count += 1
                }
            }.await {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssertEqual(result, [Int](1..<20))
    }
    
    func testAsyncFor() {
        let expectation = self.expectation(description: "testAsyncFor")
        
        var result: [Int] = []
        
        beginAsync {
            asyncFor(1...100) { i in
                foo(i).await { value in
                    result.append(value)
                }
            }.await {
                expectation.fulfill()
            }
        }

//        for i in 1...100 {
//            _ = foo(i).await { value in
//                result.append(value)
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            expectation.fulfill()
//        }

        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssertEqual(result, [Int](1...100))
    }
    
    func testAsyncForBreak() {
        let expectation = self.expectation(description: "testAsyncForBreak")
        
        var result: [Int] = []
        
        beginAsync {
            asyncFor(1...100) { i, `break` in
                foo(i).await { value -> Void in
                    if i == 20 {
                        `break`()
                        return
                    }
                    result.append(value)
                }
            }.await {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
        
        XCTAssertEqual(result, [Int](1..<20))
    }

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
                bar(a).await { b -> Void in
                    print(b)
                }
            }
            /**/ .await {
                foo().await { a in
                    bar(a)
                }.await { b -> Void in
                    print(b)
                    /**/ result = b
                    /**/ expectation.fulfill()
                }
            /**/ }
        }

        /**/ waitForExpectations(timeout: 1.0, handler: nil)
        
        /**/ XCTAssertEqual(result, 42 * 42)
    }

    static var allTests = [
        ("testAsyncFor", testAsyncFor),
        ("testAsyncForBreak", testAsyncForBreak),
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

func foo(_ x: Int) -> Async<Int> {
    return suspendAsync { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(arc4random() % 10))) {
            continuation(x)
        }
    }
}
