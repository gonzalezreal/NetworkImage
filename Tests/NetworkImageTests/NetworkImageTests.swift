import XCTest
@testable import NetworkImage

final class NetworkImageTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(NetworkImage().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
