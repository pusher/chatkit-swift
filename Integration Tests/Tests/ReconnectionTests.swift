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
        }

        wait(for: [deleteResourcesEx], timeout: 15)

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

        wait(for: [createRolesEx, createAliceEx, createBobEx], timeout: 15)
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
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let removedFromRoomEx = expectation(description: "removed from room hook called")

        let roomName = "testroom"

        let onRemovedFromRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onRemovedFromRoom called for a different room")
                return
            }
            removedFromRoomEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.roomStore.rooms.count, 0)
            alice!.createRoom(name: roomName, addUserIDs: ["bob"]) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.count, 1)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.first!.name, roomName)
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
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, removedFromRoomEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasItsPrivacyChangedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }

            if room.isPrivate {
                onRoomUpdatedCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.roomStore.rooms.count, 0)
            alice!.createRoom(name: roomName, isPrivate: false) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.count, 1)
        XCTAssertFalse(self.aliceChatManager.currentUser!.roomStore.rooms.first!.isPrivate)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, isPrivate: true) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
            XCTAssertTrue(alice!.roomStore.rooms.first!.isPrivate)
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasItsNameChangedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"
        let newRoomName = "newname"

        let onRoomUpdated = { (room: PCRoom) in
            guard room.name == newRoomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.roomStore.rooms.count, 0)
            alice!.createRoom(name: roomName) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.count, 1)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.first!.name, roomName)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, name: newRoomName) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
            XCTAssertEqual(alice!.roomStore.rooms.first!.name, newRoomName)
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataAddedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertEqual(room.customData!["some"] as! String, "custom data", "room custom data be present")
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.roomStore.rooms.count, 0)
            alice!.createRoom(name: roomName) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.count, 1)
        XCTAssertNil(self.aliceChatManager.currentUser!.roomStore.rooms.first!.customData)
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, customData: ["some": "custom data"]) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
            XCTAssertEqual(
                self.aliceChatManager.currentUser!.roomStore.rooms.first!.customData!["some"] as! String,
                "custom data"
            )
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataRemovedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertEqual(room.customData!.keys.count, 0, "room custom data should be empty")
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.roomStore.rooms.count, 0)
            alice!.createRoom(name: roomName, customData: ["some": "custom data"]) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)

        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.count, 1)
        XCTAssertEqual(
            self.aliceChatManager.currentUser!.roomStore.rooms.first!.customData!["some"] as! String,
            "custom data"
        )

        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, customData: [:]) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
            XCTAssertEqual(alice!.roomStore.rooms.first!.customData!.keys.count, 0)
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataMutatedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")

        let roomName = "testroom"

        let onRoomUpdated = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onRoomUpdated called for a different room")
                return
            }
            XCTAssertEqual(room.customData!.keys.count, 2, "room custom data should have 2 keys")
            XCTAssertEqual(room.customData!["hello"] as! String, "world")
            XCTAssertEqual(room.customData!["chicken"] as! [String], ["curry"])
            onRoomUpdatedCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.rooms.count, 0, "alice has the wrong number of rooms")
            alice!.createRoom(name: roomName, customData: ["some": "custom data"]) { room, err in
                XCTAssertNil(err)
                roomID = room!.id
                roomCreatedEx.fulfill()
            }
        }

        wait(for: [addedToRoomEx, roomCreatedEx], timeout: 15)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.count, 1)
        XCTAssertEqual(
            self.aliceChatManager.currentUser!.roomStore.rooms.first!.customData!["some"] as! String,
            "custom data"
        )
        self.aliceChatManager.disconnect()

        updateRoom(id: roomID, customData: ["hello": "world", "chicken": ["curry"]]) { err in
            XCTAssertNil(err)
            roomUpdatedEx.fulfill()
        }

        wait(for: [roomUpdatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
            XCTAssertEqual(
                alice!.roomStore.rooms.first!.customData!["hello"] as! String,
                "world"
            )
            XCTAssertEqual(
                alice!.roomStore.rooms.first!.customData!["chicken"] as! [String],
                ["curry"]
            )
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnRoomUpdatedIsCalledIfARoomHasCustomDataMutatedAndItsNameAndPrivacyChangedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let onRoomUpdatedCalledEx = expectation(description: "room updated hook called")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")

        let roomName = "testroom"
        let newRoomName = "newname"

        let onRoomUpdated = { (room: PCRoom) in
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

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice!.roomStore.rooms.count, 0)
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
        XCTAssertFalse(self.aliceChatManager.currentUser!.roomStore.rooms.first!.isPrivate)
        XCTAssertEqual(self.aliceChatManager.currentUser!.roomStore.rooms.first!.name, roomName)
        XCTAssertEqual(
            self.aliceChatManager.currentUser!.roomStore.rooms.first!.customData!["some"] as! String,
            "custom data"
        )
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
            XCTAssertTrue(alice!.roomStore.rooms.first!.isPrivate)
            XCTAssertEqual(alice!.roomStore.rooms.first!.name, newRoomName)
            XCTAssertEqual(
                alice!.roomStore.rooms.first!.customData!["hello"] as! String,
                "world"
            )
            XCTAssertEqual(
                alice!.roomStore.rooms.first!.customData!["chicken"] as! [String],
                ["curry"]
            )
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onRoomUpdatedCalledEx], timeout: 15)
    }

    func testOnAddedToRoomIsCalledIfCurrentUserHasBeenAddedToARoomBetweenConnections() {
        let roomCreatedEx = expectation(description: "room created")
        let connectedSuccessfullyEx = expectation(description: "alice connected successfully")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onAddedToRoomCalledEx = expectation(description: "added to room hook called")

        let roomName = "testroom"

        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            onAddedToRoomCalledEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onAddedToRoom: onAddedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 0, "alice has the wrong number of rooms")
            connectedSuccessfullyEx.fulfill()
        }

        wait(for: [connectedSuccessfullyEx], timeout: 15)
        self.aliceChatManager.disconnect()

        createRoom(creatorID: "bob", name: roomName, addUserIDs: ["alice"]) { err, _ in
            XCTAssertNil(err)
            roomCreatedEx.fulfill()
        }

        wait(for: [roomCreatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onAddedToRoomCalledEx], timeout: 15)
    }

    func testNoHooksAreCalledOnFirstInitialStateWhenCurrentUserIsAlreadyAMemberOfARoom() {
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")

        let roomName = "testroom"

        let onAddedToRoom = { (room: PCRoom) in
            XCTFail("onAddedToRoom called when it shouldn't have been")
        }

        let onRoomUpdated = { (room: PCRoom) in
            XCTFail("onRoomUpdated called when it shouldn't have been")
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var roomID: String!

        createRoom(creatorID: "alice", name: roomName, addUserIDs: ["bob"]) { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            roomID = roomIDFromJSON

            roomCreatedEx.fulfill()
        }
        wait(for: [roomCreatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.subscribeToRoomMultipart(id: roomID, roomDelegate: TestingRoomDelegate()) { err in
                XCTAssertNil(err)
                subscribedToRoomEx.fulfill()
                XCTAssertEqual(alice!.roomStore.rooms.count, 1)
                XCTAssertEqual(alice!.roomStore.rooms.first!.id, roomID)
                XCTAssertEqual(alice!.roomStore.rooms.first!.name, roomName)
                XCTAssertTrue(alice!.roomStore.rooms.first!.userIDs.contains("alice"))
            }
        }

        wait(for: [subscribedToRoomEx], timeout: 15)
    }


    // MARK: User cursors subscription reconciliation

    func testOnNewReadCursorIsCalledIfCurrentUserHasTheirCursorUpdatedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let initialCursorSetEx = expectation(description: "initial cursor set")
        let cursorUpdateEx = expectation(description: "cursor updated")
        let firstOnNewCursorHookCalledEx = expectation(description: "first new cursor hook called")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook called")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")

        let roomName = "testroom"

        let onNewReadCursor = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor called for a different room")
                return
            }
            if cursor.position == 99 {
                firstOnNewCursorHookCalledEx.fulfill()
            }
            if cursor.position == 100 {
                onNewReadCursorCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) in
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
            XCTAssertEqual(alice.cursorStore.cursors.keys.count, 0)
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
        wait(for: [initialCursorSetEx, firstOnNewCursorHookCalledEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 99)

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

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice.rooms.count, 1, "alice has the wrong number of rooms")
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onNewReadCursorCalledEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 100)
    }

    func testOnNewReadCursorIsCalledIfCurrentUserHasACursorSetBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let cursorSetEx = expectation(description: "cursor set")
        let connectedSuccessfullySecondEx = expectation(description: "alice connected successfully a second time")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook called")

        let roomName = "testroom"

        let onNewReadCursor = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor called for a different room")
                return
            }

            if cursor.position == 100 {
                onNewReadCursorCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) in
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

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 0)

        self.aliceChatManager.disconnect()

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }
        wait(for: [cursorSetEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice.rooms.count, 1, "alice has the wrong number of rooms")
            connectedSuccessfullySecondEx.fulfill()
        }

        wait(for: [connectedSuccessfullySecondEx, onNewReadCursorCalledEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 100)
    }

    func testOnNewReadCursorIsNotCalledOnFirstInitialStateWhenCurrentUserAlreadyHasACursorSet() {
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let cursorSetEx = expectation(description: "cursor set")
        let messageSentEx = expectation(description: "message sent")

        let roomName = "testroom"

        let onNewReadCursorCM = { (cursor: PCCursor) in
            XCTFail("onNewReadCursor (CM) called when it shouldn't have been")
        }

        let onNewReadCursor = { (cursor: PCCursor) in
            XCTFail("onNewReadCursor (Room) called when it shouldn't have been")
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onNewReadCursor: onNewReadCursorCM)
        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

        var roomID: String!

        createRoom(creatorID: "alice", name: roomName, addUserIDs: ["bob"]) { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            roomID = roomIDFromJSON

            roomCreatedEx.fulfill()
        }
        wait(for: [roomCreatedEx], timeout: 15)

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }
        wait(for: [cursorSetEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.subscribeToRoomMultipart(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)
                subscribedToRoomEx.fulfill()
                XCTAssertEqual(alice!.cursorStore.cursors.keys.count, 1)
                XCTAssertEqual(alice!.cursorStore.cursors.first!.value.position, 100)
                XCTAssertEqual(alice!.cursorStore.cursors.first!.value.user.id, "alice")

                // We send a message to give some time for any cursor hook to be called
                // otherwise it might have been going to be called but didn't have
                // enough time
                alice!.sendMultipartMessage(
                    roomID: roomID,
                    parts: [PCPartRequest(.inline(PCPartInlineRequest(content:"hola!")))]
                ) { _, err in
                    XCTAssertNil(err)
                    messageSentEx.fulfill()
                }
            }
        }

        wait(for: [subscribedToRoomEx, messageSentEx], timeout: 15)
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

        XCTAssertEqual(alice!.rooms.first!.users.count, 1)
        XCTAssertEqual(alice!.rooms.first!.users.first!.id, "alice")

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

        XCTAssertEqual(alice!.rooms.first!.users.count, 2)
        let expectedUserIDs = ["alice", "bob"]
        let sortedUserIDs = alice!.rooms.first!.users.map { $0.id }.sorted()
        XCTAssertEqual(sortedUserIDs, expectedUserIDs)
    }

    func testOnUserLeftHooksAreCalledIfANewRoomMemberIsRemovedBetweenConnections() {
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

        XCTAssertEqual(alice!.rooms.first!.users.count, 2)
        let expectedUserIDs = ["alice", "bob"]
        let sortedUserIDs = alice!.rooms.first!.users.map { $0.id }.sorted()
        XCTAssertEqual(sortedUserIDs, expectedUserIDs)

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

        XCTAssertEqual(alice!.rooms.first!.users.count, 1)
        XCTAssertEqual(alice!.rooms.first!.users.first!.id, "alice")
    }

    func testOnUserJoinedIsNotCalledOnFirstInitialStateIfTheCurrentUserIsAMemberOfARoomWithOtherMembers() {
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let messageSentEx = expectation(description: "message sent")

        let roomName = "testroom"

        let onUserJoinedRoom = { (room: PCRoom, user: PCUser) in
            XCTFail("onUserJoinedRoom (CM) called when it shouldn't have been")
        }

        let onUserJoined = { (user: PCUser) in
            XCTFail("onUserJoined (Room) called when it shouldn't have been")
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onUserJoinedRoom: onUserJoinedRoom)
        let aliceRoomDelegate = TestingRoomDelegate(onUserJoined: onUserJoined)

        var roomID: String!

        createRoom(creatorID: "alice", name: roomName, addUserIDs: ["bob"]) { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            roomID = roomIDFromJSON

            roomCreatedEx.fulfill()
        }
        wait(for: [roomCreatedEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)
                subscribedToRoomEx.fulfill()
                XCTAssertEqual(alice!.roomStore.rooms.count, 1)
                XCTAssertEqual(alice!.roomStore.rooms.first!.id, roomID)
                XCTAssertEqual(alice!.roomStore.rooms.first!.name, roomName)
                XCTAssertTrue(alice!.roomStore.rooms.first!.userIDs.contains("bob"))

                // We send a message to give some time for any cursor hook to be called
                // otherwise it might have been going to be called but didn't have
                // enough time
                alice!.sendMessage(roomID: roomID, text: "blah") { _, err in
                    XCTAssertNil(err)
                    messageSentEx.fulfill()
                }
            }
        }

        wait(for: [subscribedToRoomEx, messageSentEx], timeout: 15)
    }

    // MARK: Room cursors subscription reconciliation

    func testOnNewReadCursorIsCalledIfAnotherUserHasTheirCursorUpdatedBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let initialCursorSetEx = expectation(description: "initial cursor set")
        let cursorUpdateEx = expectation(description: "cursor updated")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook (Room level) called")
        let messageSentEx = expectation(description: "message sent")

        let roomName = "testroom"

        let onNewReadCursorCM = { (cursor: PCCursor) in
            XCTFail("onNewReadCursor (CM) called when it shouldn't have been")
        }

        let onNewReadCursor = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor (Room) called for a different room")
                return
            }
            guard cursor.user.id == "bob" else {
                XCTFail("onNewReadCursor (Room) called for a different user")
                return
            }
            if cursor.position == 100 {
                onNewReadCursorCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onNewReadCursor: onNewReadCursorCM
        )
        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

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

        setReadCursor(
            userID: "bob",
            roomID: roomID,
            position: 99
        ) { err in
            XCTAssertNil(err)
            initialCursorSetEx.fulfill()
        }
        wait(for: [initialCursorSetEx], timeout: 15)

        alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
            XCTAssertNil(err)
            subscribedToRoomEx.fulfill()
        }

        wait(for: [subscribedToRoomEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 99)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.user.id, "bob")

        self.aliceChatManager.disconnect()

        setReadCursor(
            userID: "bob",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorUpdateEx.fulfill()
        }
        wait(for: [cursorUpdateEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")

            alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)

                // We send a message to give some time for any cursor hook to be called
                // otherwise it might have been going to be called but didn't have
                // enough time, and we want to ensure that the ChatManager-level hook
                // doesn't get called
                alice.sendMessage(roomID: roomID, text: "blah") { _, err in
                    XCTAssertNil(err)
                    messageSentEx.fulfill()
                }
            }
        }

        wait(for: [onNewReadCursorCalledEx, messageSentEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 100)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.user.id, "bob")
    }

    func testOnNewReadCursorIsCalledIfAnotherUserHasACursorSetBetweenConnections() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let cursorSetEx = expectation(description: "cursor set")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook called")
        let messageSentEx = expectation(description: "message sent")

        let roomName = "testroom"

        let onNewReadCursorCM = { (cursor: PCCursor) in
            XCTFail("onNewReadCursor (CM) called when it shouldn't have been")
        }

        let onNewReadCursor = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor called for a different room")
                return
            }
            guard cursor.user.id == "bob" else {
                XCTFail("onNewReadCursor (Room) called for a different user")
                return
            }
            if cursor.position == 100 {
                onNewReadCursorCalledEx.fulfill()
            }
        }

        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onNewReadCursor: onNewReadCursorCM
        )
        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

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

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 0)

        self.aliceChatManager.disconnect()

        setReadCursor(
            userID: "bob",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }
        wait(for: [cursorSetEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { _, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")

            alice.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)

                // We send a message to give some time for any cursor hook to be called
                // otherwise it might have been going to be called but didn't have
                // enough time, and we want to ensure that the ChatManager-level hook
                // doesn't get called
                alice.sendMessage(roomID: roomID, text: "blah") { _, err in
                    XCTAssertNil(err)
                    messageSentEx.fulfill()
                }
            }
        }

        wait(for: [onNewReadCursorCalledEx, messageSentEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 100)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.user.id, "bob")
    }

    // TODO: The Swift SDK deviates from the other client SDKs currently in that it calls
    // the room-level onNewReadCursor hook for cursor updates relating to the current
    // user, as well as calling the ChatManager-level onNewReadCursor hook. This is
    // something that we should fix in the next release with breaking changes, but we've
    // deemed it not worthy of its own breaking change release at this time.
    func testBothOnNewReadCursorsAreCalledIfCurrentUserHasTheirCursorUpdatedBetweenConnectionsWhenThereIsNotAnExplicitDisconnect() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let initialCursorSetEx = expectation(description: "initial cursor set")
        let cursorUpdateEx = expectation(description: "cursor updated")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook (Room level) called")
        let onNewReadCursorCalledSecondEx = expectation(description: "new cursor hook (Room level) called for second cursor")
        let onNewReadCursorCMCalledEx = expectation(description: "new cursor hook (ChatManager level) called")
        let onNewReadCursorCMCalledSecondEx = expectation(description: "new cursor hook (ChatManager level) called for second cursor")

        let roomName = "testroom"
        var onNewReadCursorCalledCount = 0
        var onNewReadCursorCMCalledCount = 0

        let onNewReadCursorCM = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor (CM) called for a different room")
                return
            }
            guard cursor.user.id == "alice" else {
                XCTFail("onNewReadCursor (CM) called for a different user")
                return
            }
            onNewReadCursorCMCalledCount += 1

            switch onNewReadCursorCMCalledCount {
            case 1: // called once via user cursor sub
                XCTAssertEqual(cursor.position, 99)
            case 2: // called once via room cursor sub
                XCTAssertEqual(cursor.position, 99)
                onNewReadCursorCMCalledEx.fulfill()
            case 3: // called once via reconciliation
                XCTAssertEqual(cursor.position, 100)
                onNewReadCursorCMCalledSecondEx.fulfill()
            default:
                XCTFail("onNewReadCursor (CM) called too many times")
            }
        }

        let onNewReadCursor = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor (Room) called for a different room")
                return
            }
            guard cursor.user.id == "alice" else {
                XCTFail("onNewReadCursor (Room) called for a different user")
                return
            }
            onNewReadCursorCalledCount += 1

            switch onNewReadCursorCalledCount {
            case 1:
                XCTAssertEqual(cursor.position, 99)
                onNewReadCursorCalledEx.fulfill()
            case 2:
                XCTAssertEqual(cursor.position, 100)
                // This needs to have been called twice - once because of the users cursor
                // subscription and once for the cursor subscription belonging to the room
                // subscription
                onNewReadCursorCalledSecondEx.fulfill()
            default:
                XCTFail("onNewReadCursor (Room) called too many times")
            }
        }


        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onNewReadCursor: onNewReadCursorCM
        )
        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

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

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 99
        ) { err in
            XCTAssertNil(err)
            initialCursorSetEx.fulfill()
        }
        wait(for: [initialCursorSetEx, onNewReadCursorCMCalledEx, onNewReadCursorCalledEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 99)

        self.aliceChatManager.currentUser?.userSubscription?.resumableSubscription.end()
        self.aliceChatManager.currentUser?.rooms.first(where: {
            $0.id == roomID
        })!.subscription!.cursorSubscription!.resumableSubscription.end()

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorUpdateEx.fulfill()
        }
        wait(for: [cursorUpdateEx], timeout: 15)

        // To cause the ended cursor subscriptions to get reesetablished we create
        // a random error and call the `handleOnError` functions of the
        // resumableSubscriptions, which will then attempt to reestablish the
        // subscriptions
        let error = PCError.currentUserIsNil

        self.aliceChatManager.currentUser?.userSubscription?.resumableSubscription.handleOnError(error: error)
        self.aliceChatManager.currentUser?.rooms.first(where: {
            $0.id == roomID
        })!.subscription!.cursorSubscription!.resumableSubscription.handleOnError(error: error)

        wait(for: [onNewReadCursorCalledSecondEx, onNewReadCursorCMCalledSecondEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 100)
    }

    func testBothOnNewReadCursorsAreCalledIfCurrentUserHasACursorSetBetweenConnectionsWhenThereIsNotAnExplicitDisconnect() {
        let addedToRoomEx = expectation(description: "alice added to room")
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let cursorSetEx = expectation(description: "cursor set")
        let onNewReadCursorCalledEx = expectation(description: "new cursor hook called")
        let onNewReadCursorCMCalledEx = expectation(description: "new cursor hook (ChatManager level) called")

        let roomName = "testroom"

        let onNewReadCursorCM = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor (CM) called for a different room")
                return
            }
            guard cursor.user.id == "alice" else {
                XCTFail("onNewReadCursor (CM) called for a different user")
                return
            }
            XCTAssertEqual(cursor.position, 100)
            onNewReadCursorCMCalledEx.fulfill()
        }

        let onNewReadCursor = { (cursor: PCCursor) in
            guard cursor.room.name == roomName else {
                XCTFail("onNewReadCursor called for a different room")
                return
            }
            guard cursor.user.id == "alice" else {
                XCTFail("onNewReadCursor (Room) called for a different user")
                return
            }
            XCTAssertEqual(cursor.position, 100)
            onNewReadCursorCalledEx.fulfill()
        }

        let onAddedToRoom = { (room: PCRoom) in
            guard room.name == roomName else {
                XCTFail("onAddedToRoom called for a different room")
                return
            }
            addedToRoomEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onNewReadCursor: onNewReadCursorCM
        )
        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

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

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 0)

        self.aliceChatManager.currentUser?.userSubscription?.resumableSubscription.end()
        self.aliceChatManager.currentUser?.rooms.first(where: {
            $0.id == roomID
        })!.subscription!.cursorSubscription!.resumableSubscription.end()

        setReadCursor(
            userID: "alice",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }
        wait(for: [cursorSetEx], timeout: 15)

        // To cause the ended cursor subscriptions to get reesetablished we create
        // a random error and call the `handleOnError` functions of the
        // resumableSubscriptions, which will then attempt to reestablish the
        // subscriptions
        let error = PCError.currentUserIsNil

        self.aliceChatManager.currentUser?.userSubscription?.resumableSubscription.handleOnError(error: error)
        self.aliceChatManager.currentUser?.rooms.first(where: {
            $0.id == roomID
        })!.subscription!.cursorSubscription!.resumableSubscription.handleOnError(error: error)

        wait(for: [onNewReadCursorCalledEx, onNewReadCursorCMCalledEx], timeout: 15)

        XCTAssertEqual(alice.cursorStore.cursors.keys.count, 1)
        XCTAssertEqual(alice.cursorStore.cursors.first!.value.position, 100)
    }

    func testOnNewReadCursorIsNotCalledOnFirstInitialStateWhenAnotherUserAlreadyHasACursorSet() {
        let roomCreatedEx = expectation(description: "room created")
        let subscribedToRoomEx = expectation(description: "subscribe to room")
        let cursorSetEx = expectation(description: "cursor set")
        let messageSentEx = expectation(description: "message sent")

        let roomName = "testroom"

        let onNewReadCursorCM = { (cursor: PCCursor) in
            XCTFail("onNewReadCursor (CM) called when it shouldn't have been")
        }

        let onNewReadCursor = { (cursor: PCCursor) in
            XCTFail("onNewReadCursor (Room) called when it shouldn't have been")
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onNewReadCursor: onNewReadCursorCM)
        let aliceRoomDelegate = TestingRoomDelegate(onNewReadCursor: onNewReadCursor)

        var roomID: String!

        createRoom(creatorID: "alice", name: roomName, addUserIDs: ["bob"]) { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            roomID = roomIDFromJSON

            roomCreatedEx.fulfill()
        }
        wait(for: [roomCreatedEx], timeout: 15)

        setReadCursor(
            userID: "bob",
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            cursorSetEx.fulfill()
        }
        wait(for: [cursorSetEx], timeout: 15)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.subscribeToRoom(id: roomID, roomDelegate: aliceRoomDelegate) { err in
                XCTAssertNil(err)
                subscribedToRoomEx.fulfill()
                XCTAssertEqual(alice!.cursorStore.cursors.keys.count, 1)
                XCTAssertEqual(alice!.cursorStore.cursors.first!.value.position, 100)
                XCTAssertEqual(alice!.cursorStore.cursors.first!.value.user.id, "bob")

                // We send a message to give some time for any cursor hook to be called
                // otherwise it might have been going to be called but didn't have
                // enough time
                alice!.sendMessage(roomID: roomID, text: "blah") { _, err in
                    XCTAssertNil(err)
                    messageSentEx.fulfill()
                }
            }
        }

        wait(for: [subscribedToRoomEx, messageSentEx], timeout: 15)
    }
}
