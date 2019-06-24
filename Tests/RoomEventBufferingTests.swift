import XCTest
import PusherPlatform
import Mockingjay
@testable import PusherChatkit

class RoomEventBufferingTests: XCTestCase {
    var chatManager: ChatManager!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        chatManager.disconnect()
        MockingjayProtocol.removeAllStubs()
    }

    func testMessagesGetBufferedUntilAllRoomSubsriptionsHaveOpened() {
        let connectEx = expectation(description: "user connected")
        let addedToRoomEx = expectation(description: "added to room")
        let subscribedEx = expectation(description: "subscribed to room")
        let onMessageHookCalledEx = expectation(description: "message received")

        let instanceLocator = "v1:test:testing"
        let tokenEndpoint = "https://testing-chatkit.com/token"
        let userID = "fakeuser"
        let roomID = "12345"
        let messageID = 789
        let messageLimit = 20

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

        let fetchUsersURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v5",
            path: "users_by_ids",
            queryItems: [
                URLQueryItem(name: "id", value: userID),
                URLQueryItem(name: "id", value: "viv")
            ]
        ).absoluteString

        let fetchUsersURLTwo = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v5",
            path: "users_by_ids",
            queryItems: [
                URLQueryItem(name: "id", value: "viv"),
                URLQueryItem(name: "id", value: userID)
            ]
        ).absoluteString

        let usersJSON = [
            [
                "id": "fakeuser",
                "name": "Fake User",
                "created_at":"2017-03-23T11:36:42Z",
                "updated_at":"2017-03-23T11:36:42Z"
            ],
            [
                "id": "viv",
                "name": "Big Viv",
                "created_at":"2017-03-23T11:36:42Z",
                "updated_at":"2017-03-23T11:36:42Z"
            ]
        ]

        stub(uri(fetchUsersURL), json(usersJSON))
        stub(uri(fetchUsersURLTwo), json(usersJSON))

        let fetchVivURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v5",
            path: "users/viv"
        ).absoluteString

        stub(uri(fetchVivURL), json([
            "id": "viv",
            "name": "Big Viv",
            "created_at":"2017-03-23T11:36:42Z",
            "updated_at":"2017-03-23T11:36:42Z"
        ]))

        let userSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v5",
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
                        },
                        "cursors": []
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)

            let initialStateSubEvent = SubscriptionEvent(data: initialStateEventData, delay: 0.0)

            let addedToRoomEventData = dataSubscriptionEventFor("""
                {
                    "event_name": "added_to_room",
                    "data": {
                        "room": {
                            "id": "\(roomID)",
                            "name": "my room",
                            "private": false,
                            "created_by_id": "viv",
                            "created_at": "2017-04-13T14:10:04Z",
                            "updated_at": "2017-04-13T14:10:04Z"
                        }
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)
            let addedToRoomSubEvent = SubscriptionEvent(data: addedToRoomEventData, delay: 1.0)

            return successResponseForRequest(
                req,
                withEvents: [initialStateSubEvent, addedToRoomSubEvent]
            )
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

        var user: PCCurrentUser!

        let cmDelegate = TestingChatManagerDelegate(
            onAddedToRoom: { room in
                guard room.id == roomID else {
                    XCTFail("onAddedToRoom called for a different room")
                    return
                }
                addedToRoomEx.fulfill()
            }
        )

        chatManager.connect(delegate: cmDelegate) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            user = currentUser
            connectEx.fulfill()
        }

        wait(for: [connectEx, addedToRoomEx], timeout: 15, enforceOrder: true)

        let roomDelegate = TestingRoomDelegate(
            onMultipartMessage: { message in
                guard message.id == messageID else {
                    XCTFail("onMultipartMessage called for a different message")
                    return
                }
                onMessageHookCalledEx.fulfill()
            }
        )

        let messageSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v5",
            path: "rooms/\(roomID)",
            queryItems: [URLQueryItem(name: "message_limit", value: String(messageLimit))]
        ).absoluteString

        stub(uri(messageSubscriptionURL)) { req in
            let messageEventData = dataSubscriptionEventFor("""
                {
                    "event_name": "new_message",
                    "data": {
                        "id": \(messageID),
                        "user_id": "viv",
                        "room_id": "1",
                        "parts": [
                            {
                                "type": "text/plain",
                                "content": "hello"
                            }
                        ],
                        "created_at":"2017-03-23T11:36:42Z",
                        "updated_at":"2017-03-23T11:36:42Z"
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)
            let messageSubEvent = SubscriptionEvent(data: messageEventData, delay: 0.0)

            return successResponseForRequest(req, withEvents: [messageSubEvent])
        }

        let membershipSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .server,
            version: "v5",
            path: "rooms/\(roomID)/memberships"
        ).absoluteString

        stub(uri(membershipSubscriptionURL)) { req in
            let initialStateEventData = dataSubscriptionEventFor("""
                {
                    "event_name": "initial_state",
                    "data": {
                        "user_ids": ["viv", "\(userID)"]
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)
            let initialStateSubEvent = SubscriptionEvent(data: initialStateEventData, delay: 2.0)

            return successResponseForRequest(req, withEvents: [initialStateSubEvent])
        }

        let roomCursorsSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .cursors,
            version: "v2",
            path: "cursors/0/rooms/\(roomID)"
        ).absoluteString

        stub(uri(roomCursorsSubscriptionURL)) { req in
            let initialStateEventData = dataSubscriptionEventFor("""
                {
                    "event_name": "initial_state",
                    "data": {
                      "cursors": []
                    },
                    "timestamp": "2017-03-23T11:36:42Z"
                }
            """)

            let initialStateSubEvent = SubscriptionEvent(data: initialStateEventData, delay: 3.0)
            return successResponseForRequest(req, withEvents: [initialStateSubEvent])
        }

        let vivUserPresenceSubscriptionURL = serviceURL(
            instanceLocator: instanceLocator,
            service: .presence,
            version: "v2",
            path: "users/viv"
        ).absoluteString

        stub(uri(vivUserPresenceSubscriptionURL)) { req in
            return successResponseForRequest(req, withEvents: [])
        }

        user.subscribeToRoomMultipart(
            id: roomID,
            roomDelegate: roomDelegate,
            messageLimit: messageLimit
        ) { err in
            XCTAssertNil(err)
            subscribedEx.fulfill()
        }

        wait(for: [subscribedEx, onMessageHookCalledEx], timeout: 15, enforceOrder: true)
    }

}
