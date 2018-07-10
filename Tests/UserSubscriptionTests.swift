import XCTest
import PusherPlatform
@testable import PusherChatkit

class UserSubscriptionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testThatWeCanConnect() {
        let tokenEndpoint = testInstanceTokenProviderURL

        let chatManager = ChatManager(
            instanceLocator: testInstanceLocator,
            tokenProvider: PCTokenProvider(url: tokenEndpoint),
            userId: "ash",
            logger: TestLogger()
        )

        let ex = expectation(description: "Get currentUser back when connecting")

        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
