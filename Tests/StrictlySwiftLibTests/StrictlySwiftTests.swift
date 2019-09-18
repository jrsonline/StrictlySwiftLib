import XCTest
@testable import StrictlySwiftLib

final class StrictlySwiftLibTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(StrictlySwift().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
