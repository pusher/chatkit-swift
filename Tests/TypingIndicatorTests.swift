import XCTest
import PusherPlatform
@testable import PusherChatkit

class TypingIndicatorTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var roomID: Int!

    override func setUp() {
        super.setUp()

        aliceChatManager = newTestChatManager(userID: "alice")
        bobChatManager = newTestChatManager(userID: "bob")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createRoomEx = expectation(description: "create room")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()

            createStandardInstanceRoles() { err in
                XCTAssertNil(err)
                createRolesEx.fulfill()
            }

            createUser(id: "alice") { err in
                XCTAssertNil(err)
                createAliceEx.fulfill()
            }

            createUser(id: "bob") { err in
                XCTAssertNil(err)
                createBobEx.fulfill()
            }

            // TODO the following should really wait until we know both Alice
            // and Bob exist... for now, sleep!
            sleep(1)

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
                XCTAssertNil(err)
                alice!.createRoom(name: "mushroom", addUserIDs: ["bob"]) { room, err in
                    XCTAssertNil(err)
                    self.roomID = room!.id
                    createRoomEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
        roomID = nil
    }

    func testChatManagerDelegateTypingHooks() {
        let aliceChatManager = newTestChatManager(userId: "alice")

        let startedEx = expectation(description: "notified of Bob starting typing (user)")
        let stoppedEx = expectation(description: "notified of Bob stopping typing (user)")

        var started: Date!

        let userStartedTyping = { (room: PCRoom, user: PCUser) -> Void in
            started = Date()
            XCTAssertEqual(room.id, self.roomID)
            XCTAssertEqual(user.id, "bob")
            startedEx.fulfill()
        }

        let userStoppedTyping = { (room: PCRoom, user: PCUser) -> Void in
            let interval = Date().timeIntervalSince(started)

            XCTAssertGreaterThan(interval, 1)
            XCTAssertLessThan(interval, 5)

            XCTAssertEqual(room.id, self.roomID)
            XCTAssertEqual(user.id, "bob")

            stoppedEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            userStartedTyping: userStartedTyping,
            userStoppedTyping: userStoppedTyping
        )

        aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)

            alice!.subscribeToRoom(
                room: alice!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: TestingRoomDelegate()
            ) { err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    bob!.typing(in: bob!.rooms.first(where: { $0.id == self.roomId })!) { err in
                        XCTAssertNil(err)
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testRoomDelegateTypingHooks() {
        let startedEx = expectation(description: "notified of Alice starting typing (room)")
        let stoppedEx = expectation(description: "notified of Alice stopping typing (room)")

        var started: Date!

        let userStartedTyping = { (user: PCUser) -> Void in
            started = Date()
            XCTAssertEqual(user.id, "alice")
            startedEx.fulfill()
        }

        let userStoppedTyping = { (user: PCUser) -> Void in
            let interval = Date().timeIntervalSince(started)

            XCTAssertGreaterThan(interval, 1)
            XCTAssertLessThan(interval, 5)

            XCTAssertEqual(user.id, "alice")

            stoppedEx.fulfill()
        }

        let bobRoomDelegate = TestingRoomDelegate(
            userStartedTyping: userStartedTyping,
            userStoppedTyping: userStoppedTyping
        )

        self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)
            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: bobRoomDelegate
            ) { err in
                XCTAssertNil(err)
                self.aliceChatManager.connect(
                    delegate: TestingChatManagerDelegate()
                ) { alice, err in
                    XCTAssertNil(err)
                    alice!.typing(in: alice!.rooms.first(where: { $0.id == self.roomID })!) { err in
                        XCTAssertNil(err)
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }
}
