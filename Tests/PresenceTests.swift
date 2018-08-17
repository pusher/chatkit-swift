import XCTest
import PusherPlatform
@testable import PusherChatkit

class PresenceTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var charlieChatManager: ChatManager!
    var roomID: Int!

    override func setUp() {
        super.setUp()

        // We use a third user, Charlie, to create a room so that Charlie's
        // presence state isn't lingering around and messing up the tests

        aliceChatManager = newTestChatManager(userID: "alice")
        bobChatManager = newTestChatManager(userID: "bob")
        charlieChatManager = newTestChatManager(userID: "charlie")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createCharlieEx = expectation(description: "create Charlie")
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

            createUser(id: "charlie") { err in
                XCTAssertNil(err)
                createCharlieEx.fulfill()
            }

            // TODO the following should really wait until we know Alice, Bob,
            // and Charlie exist... for now, sleep!
            sleep(1)

            self.charlieChatManager.connect(delegate: TestingChatManagerDelegate()) { charlie, err in
                XCTAssertNil(err)
                charlie!.createRoom(name: "mushroom", addUserIDs: ["alice", "bob"]) { room, err in
                    XCTAssertNil(err)
                    self.roomID = room!.id
                    self.charlieChatManager.disconnect()
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
        charlieChatManager.disconnect()
        charlieChatManager = nil
        roomID = nil
    }

    func testChatManagerDelegatePresenceHooks() {
        let initialPresenceEx = expectation(description: "notified of Bob initially being offline (user)")
        let onlineEx = expectation(description: "notified of Bob coming online (user)")
        let offlineEx = expectation(description: "notified of Bob going offline (user)")

        let userPresenceChanged = { (previous: PCPresenceState, current: PCPresenceState, user: PCUser) -> Void in
            guard user.id != "charlie" else { return }
            XCTAssertEqual(user.id, "bob")

            if case .unknown = previous, case .offline = current {
                initialPresenceEx.fulfill()
            } else if case .offline = previous, case .online = current {
                onlineEx.fulfill()
                self.bobChatManager.disconnect()
            } else if case .online = previous, case .offline = current {
                offlineEx.fulfill()
            }
        }

        let aliceCMDelegate = TestingChatManagerDelegate(userPresenceChanged: userPresenceChanged)

        aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.subscribeToRoom(
                room: alice!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: TestingRoomDelegate()
            ) { err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                    XCTAssertNil(err)
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testRoomDelegatePresenceHooks() {
        let initialPresenceEx = expectation(description: "notified of Alice initially being offline (room)")
        let onlineEx = expectation(description: "notified of Alice coming online (room)")
        let offlineEx = expectation(description: "notified of Alice going offline (room)")

        let userPresenceChanged = { (previous: PCPresenceState, current: PCPresenceState, user: PCUser) -> Void in
            guard user.id != "charlie" else { return }
            XCTAssertEqual(user.id, "alice")

            if case .unknown = previous, case .offline = current {
                initialPresenceEx.fulfill()
            } else if case .offline = previous, case .online = current {
                onlineEx.fulfill()
                self.aliceChatManager.disconnect()
            } else if case .online = previous, case .offline = current {
                offlineEx.fulfill()
            }
        }

        let bobRoomDelegate = TestingRoomDelegate(userPresenceChanged: userPresenceChanged)

        self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)
            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: bobRoomDelegate
            ) { err in
                XCTAssertNil(err)
                self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                    XCTAssertNil(err)
                }
            }
        }

        waitForExpectations(timeout: 15)
    }
}
