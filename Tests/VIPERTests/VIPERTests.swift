import XCTest
@testable import VIPER

final class VIPERTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(VIPER().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
