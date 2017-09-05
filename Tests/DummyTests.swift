import PusherChatkit
import XCTest

class DummyTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testSubscribingToAPrivateChannelShouldMakeARequestToTheAuthEndpoint() {
        XCTAssertTrue(2 == 1 + 1, "maths")
    }
}
