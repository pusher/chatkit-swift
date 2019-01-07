import XCTest
import PusherPlatform
@testable import PusherChatkit

class ReconnectionTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var roomID: String!

    override func setUp() {
        super.setUp()

        aliceChatManager = newTestChatManager(userID: "alice")
        bobChatManager = newTestChatManager(userID: "bob")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()

            createStandardInstanceRoles() { err in
                XCTAssertNil(err)
                createRolesEx.fulfill()
            }

            createUser(
                id: "alice",
                name: "Alice Smith",
                avatarURL: "https://alice.avatar.com",
                customData: ["custom": "data"]
            ) { err in
                XCTAssertNil(err)
                createAliceEx.fulfill()
            }

            createUser(id: "bob") { err in
                XCTAssertNil(err)
                createBobEx.fulfill()
            }

            sleep(1)
        }

        waitForExpectations(timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
    }

    // MARK: PCCurrentUser properties are updated if they've been changed

    func testCurrentUserPropertiesAreUpdatedIfChangedWhileClientIsBrieflyDisconnected() {
        let aliceUpdatedEx = expectation(description: "alice updated")
        let aliceConnectedEx = expectation(description: "alice connected")
        let currentUserUpdatedEx = expectation(description: "current user object updated successfully")

        var aliceCurrentUser: PCCurrentUser!
        let aliceCMDelegate = TestingChatManagerDelegate()

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            aliceCurrentUser = alice!
            XCTAssertEqual(aliceCurrentUser.name!, "Alice Smith")
            XCTAssertEqual(aliceCurrentUser.avatarURL!, "https://alice.avatar.com")
            XCTAssertEqual(aliceCurrentUser.customData!.keys.count, 1)
            XCTAssertEqual(aliceCurrentUser.customData!["custom"] as! String, "data")
            aliceConnectedEx.fulfill()
        }
        wait(for: [aliceConnectedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateUser(
            id: "alice",
            name: "New Improved Alice",
            avatarURL: "https://new.alice.avatar",
            customData: ["some": "custom DATA"]
        ) { err in
            XCTAssertNil(err)
            aliceUpdatedEx.fulfill()
        }
        wait(for: [aliceUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(aliceCurrentUser.name!, "New Improved Alice")
            XCTAssertEqual(aliceCurrentUser.avatarURL!, "https://new.alice.avatar")
            XCTAssertEqual(aliceCurrentUser.customData!.keys.count, 1)
            XCTAssertEqual(aliceCurrentUser.customData!["some"] as! String, "custom DATA")
            currentUserUpdatedEx.fulfill()
        }

        wait(for: [currentUserUpdatedEx], timeout: 15)
    }

    // MARK: User subscription reconciliation

    func testOnRemovedFromRoomIsCalledIfCurrentUserHasBeenRemovedFromARoomBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let aliceRemovedFromRoomEx = expectation(description: "alice removed from room")
        let removedFromRoomEx = expectation(description: "removed from room hook called")

        let roomName = "testroom"

        let onRemovedFromRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onRemovedFromRoom called for a different room")
                return
            }
            removedFromRoomEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRemovedFromRoom: onRemovedFromRoom
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: roomName, addUserIDs: ["bob"]) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)
            bob!.removeUser(id: "alice", from: roomID) { err in
                XCTAssertNil(err)
                aliceRemovedFromRoomEx.fulfill()
            }
        }

        wait(for: [aliceRemovedFromRoomEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 0, "alice has the wrong number of rooms")
        }

        wait(for: [removedFromRoomEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasItsPrivacyChangedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }

            if room.isPrivate {
                onRoomUpdatedCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: roomName, isPrivate: false) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, isPrivate: true) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasItsNameChangedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"
        let newRoomName = "newname"

        let onRoomUpdated = { (room: PCRoom) -> Void in
            guard room.name == newRoomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: roomName) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, name: newRoomName) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataAddedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertEqual(room.customData!["some"] as! String, "custom data", "room custom data be present")
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: roomName) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, customData: ["some": "custom data"]) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataRemovedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertEqual(room.customData!.keys.count, 0, "room custom data should be empty")
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: roomName, customData: ["some": "custom data"]) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, customData: [:]) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataMutatedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertEqual(room.customData!.keys.count, 2, "room custom data should have 2 keys")
            XCTAssertEqual(room.customData!["hello"] as! String, "world")
            XCTAssertEqual(room.customData!["chicken"] as! [String], ["curry"])
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: roomName, customData: ["some": "custom data"]) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, customData: ["hello": "world", "chicken": ["curry"]]) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataMutatedAndItsNameAndPrivacyChangedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"
        let newRoomName = "newname"

        let onRoomUpdated = { (room: PCRoom) -> Void in
            guard room.name == newRoomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertTrue(room.isPrivate)
            XCTAssertEqual(room.customData!.keys.count, 2, "room custom data should have 2 keys")
            XCTAssertEqual(room.customData!["hello"] as! String, "world")
            XCTAssertEqual(room.customData!["chicken"] as! [String], ["curry"])
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(
                name: roomName,
                isPrivate: false,
                customData: ["some": "custom data"]
            ) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        self.aliceChatManager.disconnect()

        updateRoom(
            id: roomID,
            name: newRoomName,
            isPrivate: true,
            customData: ["hello": "world", "chicken": ["curry"]]
        ) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnAddedToRoomIsCalledIfCurrentUserHasBeenAddedToARoomBetweenConnections() {
        let roomCreatedEx = expectation(description: "room created")
        let connectedSuccessfullyEx = expectation(description: "alice connected successfully")
        let onAddedToRoomCalledEx = expectation(description: "added to room hook called")

        let roomName = "testroom"

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            onAddedToRoomCalledEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onAddedToRoom: onAddedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            connectedSuccessfullyEx.fulfill()
        }

        wait(for: [connectedSuccessfullyEx], timeout: 15)
        self.aliceChatManager.disconnect()

        createRoom(creatorID: "bob", name: roomName, addUserIDs: ["alice"]) { err in
            XCTAssertNil(err)
            roomCreatedEx.fulfill()
        }

        wait(for: [roomCreatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onAddedToRoomCalledEx], timeout: 15)
    }

    // MARK: User cursors subscription reconciliation

    func testOnNewReadCursorInIsCalledIfCurrentUserHasTheirCursorUpdatedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let initialCursorSetEx = expectation(description: "initial cursor set")
        let cursorUpdateEx = expectation(description: "cursor updated")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook called")

        let roomName = "testroom"

        let onNewReadCursor = { (cursor: PCCursor) -> Void in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor called for a different room")
                return
            }

            if cursor.position == 100 {
                onNewReadCursorCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onNewReadCursor: onNewReadCursor
        )

        var roomID: String!
        var alice: PCCurrentUser!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { a, err in
            XCTAssertNil(err)
            alice = a
            alice.createRoom(name: roomName, isPrivate: false) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }
        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 99
        ) { err in
            XCTAssertNil(err)
            initialCursorSetEx.fulfill()
        }
        wait(for: [initialCursorSetEx], timeout: 15)

        alice.subscribeToRoom(id: roomID, roomDelegate: TestingRoomDelegate()) { err in
            XCTAssertNil(err)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)
        self.aliceChatManager.disconnect()

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorUpdateEx.fulfill()
        }
        wait(for: [cursorUpdateEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onNewReadCursorCalledEx], timeout: 15)
    }

    func testOnNewReadCursorInIsCalledIfCurrentUserHasACursorSetBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let cursorSeteEx = expectation(description: "cursor set")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook called")

        let roomName = "testroom"

        let onNewReadCursor = { (cursor: PCCursor) -> Void in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor called for a different room")
                return
            }

            if cursor.position == 100 {
                onNewReadCursorCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) -> Void in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onNewReadCursor: onNewReadCursor
        )

        var roomID: String!
        var alice: PCCurrentUser!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { a, err in
            XCTAssertNil(err)
            alice = a
            alice.createRoom(name: roomName, isPrivate: false) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }
        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)

        alice.subscribeToRoom(id: roomID, roomDelegate: TestingRoomDelegate()) { err in
            XCTAssertNil(err)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)
        self.aliceChatManager.disconnect()

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorSeteEx.fulfill()
        }
        wait(for: [cursorSeteEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
        }

        wait(for: [onNewReadCursorCalledEx], timeout: 15)
    }

    // MARK: Membership subscription reconciliation

    func testOnUserJoinedHooksAreCalledIfANewRoomMemberIsAddedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let userAddedToRoom = expectation(description: "user added to room")
        let onUserJoinedCalledEx = expectation(description: "user joined hook (Room level) called")
        let onUserJoinedRoomCalledEx = expectation(description: "user joined room hook (ChatManager level) called")

        let roomName = "testroom"

        let onUserJoinedRoom = { (room: PCRoom, user: PCUser) in
            guard room.name == roomName else {
                XCTFail("onUserJoinedRoom called for a different room")
                return
            }
            guard user.id == "bob" else {
                XCTFail("onUserJoinedRoom called for a different user")
                return
            }
            onUserJoinedRoomCalledEx.fulfill()
        }

        let onUserJoined = { (user: PCUser) in
            guard user.id == "bob" else {
                XCTFail("onUserJoined called for a different user")
                return
            }
            onUserJoinedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onUserJoinedRoom: onUserJoinedRoom,
            onAddedToRoom: onAddedToRoom
        )
        let aliceRoomDelegate = TestingRoomDelegate(onUserJoined: onUserJoined)

        var roomID: String!
        var alice: PCCurrentUser!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { a, err in
            XCTAssertNil(err)
            alice = a
            alice.createRoom(name: roomName, isPrivate: false) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }
        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)

        alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
            XCTAssertNil(err)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)
        self.aliceChatManager.disconnect()


        addUserToRoom(roomID: roomID, userID: "bob") { err in
            XCTAssertNil(err)
            userAddedToRoom.fulfill()
        }
        wait(for: [userAddedToRoom], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")

            alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)
            }
        }

        wait(for: [onUserJoinedCalledEx, onUserJoinedRoomCalledEx], timeout: 15)
    }

    func testOnUserLeftHooksAreCalledIfANewRoomMemberIsAddedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let userRemovedFromRoom = expectation(description: "user removed from room")
        let onUserLeftCalledEx = expectation(description: "user left hook (Room level) called")
        let onUserLeftRoomCalledEx = expectation(description: "user left room hook (ChatManager level) called")

        let roomName = "testroom"

        let onUserLeftRoom = { (room: PCRoom, user: PCUser) in
            guard room.name == roomName else {
                XCTFail("onUserLeftRoom called for a different room")
                return
            }
            guard user.id == "bob" else {
                XCTFail("onUserLeftRoom called for a different user")
                return
            }
            onUserLeftRoomCalledEx.fulfill()
        }

        let onUserLeft = { (user: PCUser) in
            guard user.id == "bob" else {
                XCTFail("onUserLeft called for a different user")
                return
            }
            onUserLeftCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onUserLeftRoom: onUserLeftRoom,
            onAddedToRoom: onAddedToRoom
        )
        let aliceRoomDelegate = TestingRoomDelegate(onUserLeft: onUserLeft)

        var roomID: String!
        var alice: PCCurrentUser!

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { a, err in
            XCTAssertNil(err)
            alice = a
            alice.createRoom(
                name: roomName,
                isPrivate: false,
                addUserIDs: ["bob"]
            ) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }
        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)

        alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
            XCTAssertNil(err)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)
        self.aliceChatManager.disconnect()


        removeUserFromRoom(roomID: roomID, userID: "bob") { err in
            XCTAssertNil(err)
            userRemovedFromRoom.fulfill()
        }
        wait(for: [userRemovedFromRoom], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")

            alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)
            }
        }

        wait(for: [onUserLeftCalledEx, onUserLeftRoomCalledEx], timeout: 15)
    }
}
