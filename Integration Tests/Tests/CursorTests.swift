import XCTest
import PusherPlatform
@testable import PusherChatkit

class CursorTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var roomID: String!

    override func setUp() {
        super.setUp()

        aliceChatManager = newTestChatManager(userID: "alice")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
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

        createUser(id: "alice") { err in
            XCTAssertNil(err)
            createAliceEx.fulfill()
        }

        createUser(id: "bob") { err in
            XCTAssertNil(err)
            createBobEx.fulfill()
        }

        wait(for: [createRolesEx, createAliceEx, createBobEx], timeout: 15)

        createRoom(creatorID: "alice", name: "mushroom", addUserIDs: ["bob"]) { err, data in
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
        roomID = nil
    }

    func testOwnReadCursorUndefinedIfNotSet() {
        let connectAliceEx = expectation(description: "alice connected successfully")
        var alice: PCCurrentUser!

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { a, err in
            XCTAssertNil(err)
            alice = a
            connectAliceEx.fulfill()
        }

        wait(for: [connectAliceEx], timeout: 15)

        let cursor = try! alice.readCursor(roomID: roomID)
        XCTAssertNil(cursor)
    }

    // TODO hook for setting own read cursor? (currently unsupported by the looks of it)

    func testGetOwnReadCursor() {
        let connectAliceEx = expectation(description: "alice connected successfully")
        let cursorReceivedEx = expectation(description: "read cursor received")
        let cursorSetEx = expectation(description: "read cursor set")

        var alice: PCCurrentUser!

        let aliceCMDelegate = TestingChatManagerDelegate(
            onNewReadCursor: { cursor in
                XCTAssertEqual(cursor.position, 42)
                cursorReceivedEx.fulfill()
            }
        )

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { a, err in
            XCTAssertNil(err)
            alice = a
            connectAliceEx.fulfill()
        }

        wait(for: [connectAliceEx], timeout: 15)

        alice.setReadCursor(position: 42, roomID: roomID) { error in
            XCTAssertNil(error)
            cursorSetEx.fulfill()
        }

        wait(for: [cursorSetEx, cursorReceivedEx], timeout: 15)

        let cursor = try! alice.readCursor(roomID: self.roomID)
        XCTAssertEqual(cursor?.position, 42)
    }

    func testOnNewReadCursorHook() {
        let connectAliceEx = expectation(description: "alice connected successfully")
        let subscribedToRoomEx = expectation(description: "alice subscribed to the room")
        let cursorSetEx = expectation(description: "read cursor set")
        let onNewReadCursorHookCalledEx = expectation(description: "received new read cursor")

        var alice: PCCurrentUser!

        let onNewReadCursor = { (cursor: PCCursor) -> Void in
            XCTAssertEqual(cursor.position, 42)
            onNewReadCursorHookCalledEx.fulfill()
        }

        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { a, err in
            XCTAssertNil(err)
            alice = a
            connectAliceEx.fulfill()
        }

        wait(for: [connectAliceEx], timeout: 15)

        alice.subscribeToRoom(
            room: alice.rooms.first(where: { $0.id == self.roomID })!,
            roomDelegate: aliceRoomDelegate
        ) { error in
            XCTAssertNil(error)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)

        setReadCursor(userID: "bob", roomID: self.roomID, position: 42) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }

        wait(for: [cursorSetEx, onNewReadCursorHookCalledEx], timeout: 15)
    }

    func testGetAnotherUsersReadCursorBeforeSubscribingFails() {
        let connectAliceEx = expectation(description: "alice connected successfully")
        let cursorSetEx = expectation(description: "read cursor set")
        let getReadCursorFailsEx = expectation(description: "get another user's read cursor fails")

        var alice: PCCurrentUser!

        setReadCursor(userID: "bob", roomID: self.roomID, position: 42) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }

        wait(for: [cursorSetEx], timeout: 15)

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { a, err in
            XCTAssertNil(err)
            alice = a
            connectAliceEx.fulfill()
        }

        wait(for: [connectAliceEx], timeout: 15)

        do {
            let _ = try alice.readCursor(roomID: self.roomID, userID: "bob")
        } catch let error {
            switch error {
            case PCCurrentUserError.noSubscriptionToRoom:
                getReadCursorFailsEx.fulfill()
            default:
                XCTFail()
            }
        }

        wait(for: [getReadCursorFailsEx], timeout: 15)
    }

    func testGetAnotherUsersReadCursor() {
        let connectAliceEx = expectation(description: "alice connected successfully")
        let cursorSetEx = expectation(description: "read cursor set")
        let subscribedToRoomEx = expectation(description: "alice subscribed to the room")
        let onNewReadCursorHookCalledEx = expectation(description: "received new read cursor")

        var alice: PCCurrentUser!

        let aliceRoomDelegate = TestingRoomDelegate(
            onNewReadCursor: { cursor in
                XCTAssertEqual(cursor.position, 42)
                onNewReadCursorHookCalledEx.fulfill()
            }
        )

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { a, err in
            XCTAssertNil(err)
            alice = a
            connectAliceEx.fulfill()
        }

        wait(for: [connectAliceEx], timeout: 15)

        alice.subscribeToRoom(
            room: alice.rooms.first(where: { $0.id == self.roomID })!,
            roomDelegate: aliceRoomDelegate
        ) { error in
            XCTAssertNil(error)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)

        setReadCursor(userID: "bob", roomID: self.roomID, position: 42) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }

        wait(for: [cursorSetEx, onNewReadCursorHookCalledEx], timeout: 15)

        let cursor = try! alice.readCursor(roomID: self.roomID, userID: "bob")
        XCTAssertEqual(cursor?.position, 42)
    }
}
