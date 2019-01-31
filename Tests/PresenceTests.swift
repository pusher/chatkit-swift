import XCTest
import PusherPlatform
@testable import PusherChatkit

class PresenceTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var charlieChatManager: ChatManager!
    var roomID: String!

    let uniqueAlice = "alice-\(UUID().uuidString)"
    let uniqueBob = "bob-\(UUID().uuidString)"

    override func setUp() {
        super.setUp()

        // We use a third user, Charlie, to create a room so that Charlie's
        // presence state isn't lingering around and messing up the tests.
        // This is also the reason we use unique suffixed IDs for Alice and
        // Bob; to avoid lingering presence states.

        aliceChatManager = newTestChatManager(userID: uniqueAlice)
        bobChatManager = newTestChatManager(userID: uniqueBob)

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createCharlieEx = expectation(description: "create Charlie")
        let createRoomEx = expectation(description: "create room")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()
        }

        wait(for: [deleteResourcesEx], timeout: 15)

        createStandardInstanceRoles() { err in
            XCTAssertNil(err)
            createRolesEx.fulfill()
        }

        createUser(id: self.uniqueAlice) { err in
            XCTAssertNil(err)
            createAliceEx.fulfill()
        }

        createUser(id: self.uniqueBob) { err in
            XCTAssertNil(err)
            createBobEx.fulfill()
        }

        createUser(id: "charlie") { err in
            XCTAssertNil(err)
            createCharlieEx.fulfill()
        }

        wait(for: [createRolesEx, createAliceEx, createBobEx, createCharlieEx], timeout: 10)

        createRoom(
            creatorID: "charlie",
            name: "mushroom",
            addUserIDs: [self.uniqueAlice, self.uniqueBob]
        ) { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            self.roomID = roomIDFromJSON

            createRoomEx.fulfill()
        }

        wait(for: [createRoomEx], timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
        roomID = nil
    }

    func testChatManagerDelegatePresenceHooks() {
        let aliceConnectedEx = expectation(description: "alice connected")
        let aliceSubscribedEx = expectation(description: "alice subscribed to room")
        let bobConnectedEx = expectation(description: "bob connected")
        let initialPresenceEx = expectation(description: "notified of Bob initially being offline (user)")
        let onlineEx = expectation(description: "notified of Bob coming online (user)")
        let offlineEx = expectation(description: "notified of Bob going offline (user)")

        let onPresenceChanged = { (stateChange: PCPresenceStateChange, user: PCUser) -> Void in
            guard user.id != "charlie" else { return }
            XCTAssertEqual(user.id, self.uniqueBob)

            if case .unknown = stateChange.previous, case .offline = stateChange.current {
                initialPresenceEx.fulfill()
            } else if case .offline = stateChange.previous, case .online = stateChange.current {
                onlineEx.fulfill()
                self.bobChatManager.disconnect()
            } else if case .online = stateChange.previous, case .offline = stateChange.current {
                offlineEx.fulfill()
            }
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onPresenceChanged: onPresenceChanged)

        var alice: PCCurrentUser!

        aliceChatManager.connect(delegate: aliceCMDelegate) { a, err in
            XCTAssertNil(err)
            alice = a
            aliceConnectedEx.fulfill()
        }
        wait(for: [aliceConnectedEx], timeout: 15)

        alice.subscribeToRoom(
            room: alice.rooms.first(where: { $0.id == self.roomID })!,
            roomDelegate: TestingRoomDelegate()
        ) { err in
            XCTAssertNil(err)
            aliceSubscribedEx.fulfill()
        }
        wait(for: [aliceSubscribedEx], timeout: 15)

        self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
            XCTAssertNil(err)
            bobConnectedEx.fulfill()
        }
        wait(for: [bobConnectedEx, initialPresenceEx, onlineEx, offlineEx], timeout: 20)
    }

    func testRoomDelegatePresenceHooks() {
        let bobConnectedEx = expectation(description: "bob connected")
        let bobSubscribedEx = expectation(description: "bob subscribed to room")
        let aliceConnectedEx = expectation(description: "bob connected")
        let initialPresenceEx = expectation(description: "notified of Alice initially being offline (room)")
        let onlineEx = expectation(description: "notified of Alice coming online (room)")
        let offlineEx = expectation(description: "notified of Alice going offline (room)")

        let onPresenceChanged = { (stateChange: PCPresenceStateChange, user: PCUser) -> Void in
            guard user.id != "charlie" else { return }
            XCTAssertEqual(user.id, self.uniqueAlice)

            if case .unknown = stateChange.previous, case .offline = stateChange.current {
                initialPresenceEx.fulfill()
            } else if case .offline = stateChange.previous, case .online = stateChange.current {
                onlineEx.fulfill()
                self.aliceChatManager.disconnect()
            } else if case .online = stateChange.previous, case .offline = stateChange.current {
                offlineEx.fulfill()
            }
        }

        let bobRoomDelegate = TestingRoomDelegate(onPresenceChanged: onPresenceChanged)

        var bob: PCCurrentUser!

        self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { b, err in
            XCTAssertNil(err)
            bob = b!
            bobConnectedEx.fulfill()
        }
        wait(for: [bobConnectedEx], timeout: 15)

        bob!.subscribeToRoom(
            room: bob!.rooms.first(where: { $0.id == self.roomID })!,
            roomDelegate: bobRoomDelegate
        ) { err in
            XCTAssertNil(err)
            bobSubscribedEx.fulfill()
        }
        wait(for: [bobSubscribedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
            XCTAssertNil(err)
            aliceConnectedEx.fulfill()
        }
        wait(for: [aliceConnectedEx, initialPresenceEx, onlineEx, offlineEx], timeout: 20)
    }
}
