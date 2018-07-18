import XCTest
import PusherPlatform
@testable import PusherChatkit

class TypingIndicatorTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var roomId: Int!

    override func setUp() {
        super.setUp()

        aliceChatManager = newTestChatManager(userId: "alice")
        bobChatManager = newTestChatManager(userId: "bob")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createRoomEx = expectation(description: "create room")

        deleteInstanceResources() { err in
            guard err == nil else {
                fatalError(err!.localizedDescription)
            }
            deleteResourcesEx.fulfill()

            createStandardInstanceRoles() { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createRolesEx.fulfill()
            }

            createUser(id: "alice") { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createAliceEx.fulfill()
            }

            createUser(id: "bob") { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createBobEx.fulfill()
            }

            // TODO the following should really wait until we know both Alice
            // and Bob exist... for now, sleep!
            sleep(1)

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
                    guard err == nil else {
                        fatalError(err!.localizedDescription)
                    }
                    self.roomId = room!.id
                    createRoomEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
        roomId = nil
    }

    func testChatManagerDelegateTypingHooks() {
        let startedEx = expectation(description: "notified of Bob starting typing (user)")
        let stoppedEx = expectation(description: "notified of Bob stopping typing (user)")

        var started: Date!

        let userStartedTyping = { (room: PCRoom, user: PCUser) -> Void in
            started = Date.init()
            XCTAssertEqual(room.id, self.roomId)
            XCTAssertEqual(user.id, "bob")
            startedEx.fulfill()
        }

        let userStoppedTyping = { (room: PCRoom, user: PCUser) -> Void in
            let interval = Date.init().timeIntervalSince(started)

            XCTAssertGreaterThan(interval, 1)
            XCTAssertLessThan(interval, 5)

            XCTAssertEqual(room.id, self.roomId)
            XCTAssertEqual(user.id, "bob")

            stoppedEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            userStartedTyping: userStartedTyping,
            userStoppedTyping: userStoppedTyping
        )

        let bobCMDelegate = TestingChatManagerDelegate()

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _alice, err in
            XCTAssertNil(err)
            self.bobChatManager.connect(delegate: bobCMDelegate) { bob, err in
                XCTAssertNil(err)
                bob!.typing(in: bob!.rooms.first(where: { $0.id == self.roomId })!)
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testRoomDelegateTypingHooks() {
        let startedEx = expectation(description: "notified of Alice starting typing (room)")
        let stoppedEx = expectation(description: "notified of Alice stopping typing (room)")

        var started: Date!

        let userStartedTyping = { (user: PCUser) -> Void in
            started = Date.init()
            XCTAssertEqual(user.id, "alice")
            startedEx.fulfill()
        }

        let userStoppedTyping = { (user: PCUser) -> Void in
            let interval = Date.init().timeIntervalSince(started)

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
                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
                roomDelegate: bobRoomDelegate
            )

            sleep(1) // TODO remove once we can wait on the completion of subscribeToRoom

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
                XCTAssertNil(err)
                alice!.typing(in: alice!.rooms.first(where: { $0.id == self.roomId })!)
            }
        }

        waitForExpectations(timeout: 15)
    }
}
