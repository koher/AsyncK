import XCTest
import Dispatch
@testable import AsyncK

final class ThrowsTests: XCTestCase {
    func testInit() {
        do {
            let a = Throws(42)
            do {
                let value = try a.get()
                XCTAssertEqual(value, 42)
            } catch let error {
                XCTFail("\(error)")
            }
        }

        do {
            let a = Throws<Int>(error: FooError(value: -1))
            do {
                let value = try a.get()
                XCTFail("\(value)")
            } catch let error as FooError {
                XCTAssertEqual(error.value, -1)
            } catch {
                XCTFail()
            }
        }
        
        do {
            let a = Throws(try foo())
            do {
                let value: Int = try a.get()
                XCTAssertEqual(value, 42)
            } catch let error {
                XCTFail("\(error)")
            }
        }
        
        do {
            let a = Throws(try foo(error: FooError(value: -1)))
            do {
                let value = try a.get()
                XCTFail("\(value)")
            } catch let error as FooError {
                XCTAssertEqual(error.value, -1)
            } catch {
                XCTFail()
            }
        }
    }
}

private func foo(error: Error? = nil) throws -> Int {
    if let error = error {
        throw error
    }
    return 42
}

private struct FooError: Error {
    var value: Int
}
