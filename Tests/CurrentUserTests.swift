import XCTest
import PusherPlatform
import Mockingjay
@testable import PusherChatkit

class CurrentUserTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        MockingjayProtocol.removeAllStubs()
    }

    func testSendMessageWithAnAttachment() {
        let instanceLocator = "v1:test:testing"
        let tokenEndpoint = "https://testing-chatkit.com/token"
        let userID = "ash"

        let chatManager = ChatManager(
            instanceLocator: instanceLocator,
            tokenProvider: PCTokenProvider(url: tokenEndpoint),
            userId: userID,
            logger: TestLogger()
        )

        stub({ $0.url!.absoluteString == "\(tokenEndpoint)?user_id=\(userID)" }, { req in
            let tokenObj: [String : Any] = [
                "access_token": "a.good.token",
                "expires_in": 86400
            ]
            let tokenJSON = try! JSONSerialization.data(withJSONObject: tokenObj, options: [])
            let response = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(response, .content(tokenJSON))
        })

        let userSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            path: "users"
        ).absoluteString

        stub({ $0.url!.absoluteString == userSubscriptionURL }) { req in
            let initialStateEvent = """
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
            """.replacingOccurrences(of: "\n", with: "")

            let wrappedInitialStateEvent = "[1, \"\", {}, \(initialStateEvent)]\n"
            let initialStateSubEvent = SubscriptionEvent(data: wrappedInitialStateEvent.data(using: .utf8)!, delay: 0.0)
            let res = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(res, .streamSubscription(events: [initialStateSubEvent]))
        }

        let presenceSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .presence,
            path: "users/\(userID)/presence"
        ).absoluteString

        stub({ $0.url!.absoluteString == presenceSubscriptionURL }) { req in
            let initialStateEvent = """
                {
                    "event_name": "initial_state",
                    "data": {
                      "user_states": []
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """.replacingOccurrences(of: "\n", with: "")

            let wrappedInitialStateEvent = "[1, \"\", {}, \(initialStateEvent)]\n"
            let initialStateSubEvent = SubscriptionEvent(data: wrappedInitialStateEvent.data(using: .utf8)!, delay: 0.0)
            let res = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(res, .streamSubscription(events: [initialStateSubEvent]))
        }

        let cursorsSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .cursors,
            path: "cursors/0/users/\(userID)"
        ).absoluteString

        stub({ $0.url!.absoluteString == cursorsSubscriptionURL }) { req in
            let initialStateEvent = """
                {
                    "event_name": "initial_state",
                    "data": {
                      "cursors": []
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """.replacingOccurrences(of: "\n", with: "")

            let wrappedInitialStateEvent = "[1, \"\", {}, \(initialStateEvent)]\n"
            let initialStateSubEvent = SubscriptionEvent(data: wrappedInitialStateEvent.data(using: .utf8)!, delay: 0.0)
            let res = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(res, .streamSubscription(events: [initialStateSubEvent]))
        }

        let usersByIDsURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            path: "users_by_ids"
        ).absoluteString

        stub({ $0.url!.absoluteString == usersByIDsURL }, { req in
            let tokenJSON = try! JSONSerialization.data(withJSONObject: [], options: [])
            let response = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return .success(response, .content(tokenJSON))
        })

        let ex = expectation(description: "current user returned upon connection")

        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

}
