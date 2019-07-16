import XCTest
@testable import PusherChatkit

class DefaultsTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testDefaultReadCursorDebounceIntervalMillisecondsIsCorrect() {
        XCTAssertEqual(PCDefaults.readCursorDebounceIntervalMilliseconds, 500)
    }
}
