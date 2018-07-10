//import XCTest
//import PusherPlatform
//import Mockingjay
//@testable import PusherChatkit
//
//class CurrentUserTests: XCTestCase {
//    override func setUp() {
//        super.setUp()
//    }
//
//    override func tearDown() {
//        MockingjayProtocol.removeAllStubs()
//    }
//
//    func testSendMessageWithAnAttachment() {
//        let tokenEndpoint = "https://testing-chatkit.com/token"
//
//        let chatManager = ChatManager(
//            instanceLocator: "v1:test:testing",
//            tokenProvider: PCTokenProvider(url: tokenEndpoint),
//            userId: "ash",
//            logger: TestLogger()
//        )
//
//        stub({ $0.url!.absoluteString == tokenEndpoint }, { req in
//            let tokenObj: [String : Any] = [
//                "access_token": "a.good.token",
//                "expires_in": 86400
//            ]
//            let tokenJSON = try! JSONSerialization.data(withJSONObject: tokenObj, options: [])
//            let response = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return .success(response, .content(tokenJSON))
//        })
//
//        
//
//        stub({ testReq in
////            dump(testReq)
//            return testReq.url!.absoluteString == "https://test.pusherplatform.io/services/chatkit/v1/testing/users"
//        }) { req in
//            let initialStateEvent = """
//                {
//                    "event_name": "initial_state",
//                    "data": {
//                        "rooms": [],
//                        "current_user": {
//                            "id": "hamtest",
//                            "name": "Ham",
//                            "created_at": "2017-04-13T14:10:04Z",
//                            "updated_at": "2017-04-13T14:10:04Z"
//                        }
//                    },
//                    "timestamp": "2017-03-23T11:36:42Z"
//                }
//            """
//
//            let wrappedInitialStateEvent = "[1, \"\", {}, {\"data\": \(initialStateEvent)}]"
//            let initialStateSubEvent = SubscriptionEvent(data: wrappedInitialStateEvent.data(using: .utf8)!, delay: 0.0)
//
////            let subEvents = [
////                SubscriptionEvent(data: "[0, \"xxxxxxxxxxxxxxxxxxxxxxxxxxxx\"]\n".data(using: .utf8)!), // Keep-alive
////                SubscriptionEvent(data: "[255, 500, {}, {\"error_description\": \"Internal server error\" }]\n".data(using: .utf8)!), // EOS
////                SubscriptionEvent(data: "[1, \"123\", {}, {\"data\": [1,2,3]}]\n".data(using: .utf8)!) // Data
////            ]
//
//            let res = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
//            return .success(res, .streamSubscription(events: [initialStateSubEvent]))
//        }
//
//        URLSessionConfiguration.mockingjaySwizzleDefaultSessionConfiguration()
//
//        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
//            print(currentUser, error)
//        }
//
//        let ex = expectation(description: "testing")
//
//        waitForExpectations(timeout: 5)
//    }
//
//    func testSendMessageWithoutAnAttachment() {
//
//    }
//}
