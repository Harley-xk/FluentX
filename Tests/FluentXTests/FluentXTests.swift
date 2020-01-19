import XCTest
@testable import FluentX

final class FluentXTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FluentX().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
