import XCTest
import PusherPlatform
import Mockingjay
@testable import PusherChatkit

class UserStoreTests: XCTestCase {
    var chatManager: ChatManager!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        chatManager.disconnect()
        MockingjayProtocol.removeAllStubs()
    }

    func testUserStoreQueuesFetchUserRequestsIfOneIsUnderway() {
        let connectedEx = expectation(description: "user connected")
        let userFetchOneEx = expectation(description: "the returned user info should have ID viv on first token fetch")
        let userFetchTwoEx = expectation(description: "the returned user info should have ID viv on second token fetch")
        let userFetchThreeEx = expectation(description: "the returned user info should have ID viv on third token fetch")

        let instanceLocator = "v1:test:testing"
        let tokenEndpoint = "https://testing-chatkit.com/token"
        let userID = "ham"

        chatManager = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(url: tokenEndpoint),
            userID: userID,
            logger: TestLogger()
        )

        stub(uri("\(tokenEndpoint)?user_id=\(userID)"), json([
            "access_token": "a.good.token",
            "expires_in": 86400
        ]))

        let userSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v2",
            path: "users"
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
            version: "v2",
            path: "users/\(userID)/register"
        ).absoluteString

        stub(uri(presenceSubscriptionURL)) { req in
            return successResponseForRequest(req, withEvents: [])
        }

        let cursorsSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .cursors,
            version: "v2",
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

        let userIDToFetch = "viv"
        let fetchVivEndpoint = serviceURL(
            instanceLocator: instanceLocator,
            service: .server, version: "v2",
            path: "users/\(userIDToFetch)"
        ).absoluteString

        var callCount = 0

        stub(uri(fetchVivEndpoint), { req in
            let userID = callCount > 0 ? "SOMETHING ELSE WRONG" : userIDToFetch
            let userObj: [String: Any] = [
                "id": "\(userID)",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "name": "Prince Kumar"
            ]
            let userJSON = try! JSONSerialization.data(withJSONObject: userObj, options: [])
            callCount += 1
            let response = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(response, .content(userJSON))
        })

        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            connectedEx.fulfill()

            currentUser!.userStore.user(id: userIDToFetch) { user, err in
                XCTAssertNil(err)

                guard let user = user, user.id == userIDToFetch else {
                    XCTFail("Invalid user received on user fetch")
                    return
                }

                userFetchOneEx.fulfill()
            }

            currentUser!.userStore.user(id: userIDToFetch) { user, err in
                XCTAssertNil(err)

                guard let user = user, user.id == userIDToFetch else {
                    XCTFail("Invalid user received on user fetch")
                    return
                }

                userFetchTwoEx.fulfill()
            }

            currentUser!.userStore.user(id: userIDToFetch) { user, err in
                XCTAssertNil(err)

                guard let user = user, user.id == userIDToFetch else {
                    XCTFail("Invalid user received on user fetch")
                    return
                }

                userFetchThreeEx.fulfill()
            }
        }


//        tokenProvider.fetchToken() { res in
//            switch res {
//            case .success(let token):
//                guard token == "GOOD" else {
//                    XCTFail("fetched token was not the expected one")
//                    return
//                }
//                expOne.fulfill()
//            case .error(_):
//                XCTFail("error when fetching token")
//            }
//        }
//
//        tokenProvider.fetchToken() { res in
//            switch res {
//            case .success(let token):
//                guard token == "GOOD" else {
//                    XCTFail("fetched token was not the expected one")
//                    return
//                }
//                expTwo.fulfill()
//            case .error(_):
//                XCTFail("error when fetching token")
//            }
//        }

        waitForExpectations(timeout: 10)
    }
}
