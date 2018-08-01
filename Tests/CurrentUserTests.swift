import XCTest
import PusherPlatform
import Mockingjay
@testable import PusherChatkit

class CurrentUserTests: XCTestCase {
    var chatManager: ChatManager!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        chatManager.disconnect()
        MockingjayProtocol.removeAllStubs()
    }

    func testConnecting() {
        let instanceLocator = "v1:test:testing"
        let tokenEndpoint = "https://testing-chatkit.com/token"
        let userID = "ash"

        chatManager = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(url: tokenEndpoint),
            userId: userID,
            logger: TestLogger()
        )

        stub(uri("\(tokenEndpoint)?user_id=\(userID)"), json([
            "access_token": "a.good.token",
            "expires_in": 86400
        ]))

        let userSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            path: "users",
            version: "v2"
        ).absoluteString

        stub(uri(userSubscriptionURL)) { req in
            let initialStateEventData = dataSubscriptionEventFor("""
                {
                    "event_name": "initial_state",
                    "data": {
                        "rooms": [],
                        "current_user": {
                            "id": "\(userID)",
                            "name": "\(userID)",
                            "created_at": "2017-04-13T14:10:04Z",
                            "updated_at": "2017-04-13T14:10:04Z"
                        }
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)

            let initialStateSubEvent = SubscriptionEvent(data: initialStateEventData, delay: 0.0)
            return successResponseForRequest(req, withEvents: [initialStateSubEvent])
        }

        let presenceSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .presence,
            path: "users/\(userID)/register",
            version: "v2"
        ).absoluteString

        stub(uri(presenceSubscriptionURL)) { req in
            return successResponseForRequest(req, withEvents: [])
        }

        let cursorsSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .cursors,
            path: "cursors/0/users/\(userID)"
        ).absoluteString

        stub(uri(cursorsSubscriptionURL)) { req in
            let initialStateEventData = dataSubscriptionEventFor("""
                {
                    "event_name": "initial_state",
                    "data": {
                      "cursors": []
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)

            let initialStateSubEvent = SubscriptionEvent(data: initialStateEventData, delay: 0.0)
            return successResponseForRequest(req, withEvents: [initialStateSubEvent])
        }

        let ex = expectation(description: "current user returned upon connection")

        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

}
