import XCTest
import PusherPlatform
@testable import PusherChatkit

class RoomMembershipTests: XCTestCase {
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

        createUser(id: "alice") { err in
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

    // MARK: Chat manager delegate tests

    func testChatManagerUserJoinedRoomHookWhenUserJoins() {
        let userJoinedRoomHookEx = expectation(description: "user joined room hook called")
        let bobJoinedRoomEx = expectation(description: "bob joined room")

        let onUserJoinedRoom = { (room: PCRoom, user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            XCTAssertEqual(room.name, "mushroom")
            userJoinedRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onUserJoinedRoom: onUserJoinedRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom") { room, err in
                XCTAssertNil(err)
                alice!.subscribeToRoom(
                    room: room!, roomDelegate: TestingRoomDelegate()
                ) { err in
                    XCTAssertNil(err)
                    self.bobChatManager.connect(
                        delegate: TestingChatManagerDelegate()
                    ) { bob, err in
                        XCTAssertNil(err)
                        bob!.joinRoom(id: room!.id) { room, err in
                            XCTAssertNil(err)
                            bobJoinedRoomEx.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerUserLeftRoomHookWhenUserLeaves() {
        let userLeftRoomHookEx = expectation(description: "user left room hook called")
        let bobLeftRoomEx = expectation(description: "bob left room")

        let onUserLeftRoom = { (room: PCRoom, user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            XCTAssertEqual(room.name, "mushroom")
            userLeftRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onUserLeftRoom: onUserLeftRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIDs: ["bob"]) { room, err in
                XCTAssertNil(err)
                alice!.subscribeToRoom(
                    room: room!, roomDelegate: TestingRoomDelegate()
                ) { err in
                    XCTAssertNil(err)
                    self.bobChatManager.connect(
                        delegate: TestingChatManagerDelegate()
                    ) { bob, err in
                        XCTAssertNil(err)
                        bob!.leaveRoom(id: room!.id) { err in
                            XCTAssertNil(err)
                            bobLeftRoomEx.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerAddedToRoomHookCalledWhenSelfAddedInRoomCreation() {
        let addedToRoomHookEx = expectation(description: "added to room hook called when added as part of room creation")

        let onAddedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onAddedToRoom: onAddedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom") { room, err in
                XCTAssertNil(err)
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerAddedToRoomHookCalledWhenUserAddsAnotherUserInRoomCreation() {
        let addedToRoomHookEx = expectation(description: "added to room hook called when added as part of room creation")
        let bobAddAliceEx = expectation(description: "bob added alice to room when creating room")

        let onAddedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onAddedToRoom: onAddedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                XCTAssertNil(err)
                bob!.createRoom(name: "mushroom", addUserIDs: ["alice"]) { room, err in
                    XCTAssertNil(err)
                    bobAddAliceEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerAddedToRoomHookCalledWhenUserAddsAnotherUser() {
        let addedToRoomHookEx = expectation(description: "added to room hook called")
        let bobAddAliceEx = expectation(description: "bob added alice to room")

        let onAddedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onAddedToRoom: onAddedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                XCTAssertNil(err)
                bob!.createRoom(name: "mushroom") { room, err in
                    XCTAssertNil(err)
                    bob!.addUser(id: "alice", to: room!.id) { err in
                        XCTAssertNil(err)
                        bobAddAliceEx.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerRemovedFromRoomHookCalledUserRemovedFromRoom() {
        let removedFromRoomHookEx = expectation(description: "removed from room hook called")
        let bobRemoveAliceEx = expectation(description: "bob removed alice from room")

        let onRemovedFromRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            removedFromRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onRemovedFromRoom: onRemovedFromRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIDs: ["bob"]) { room, err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    bob!.removeUser(id: "alice", from: room!.id) { err in
                        XCTAssertNil(err)
                        bobRemoveAliceEx.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerRemovedFromRoomHookCalledUserRemovesSelf() {
        let removedFromRoomHookEx = expectation(description: "removed from room hook called")
        let aliceRemoveSelfEx = expectation(description: "bob removed alice from room")

        let onRemovedFromRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            removedFromRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onRemovedFromRoom: onRemovedFromRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom") { room, err in
                XCTAssertNil(err)
                alice!.removeUser(id: "alice", from: room!.id) { err in
                    XCTAssertNil(err)
                    aliceRemoveSelfEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerRoomDeletedHookCalled() {
        let assignAdminRoleEx = expectation(description: "assign alice admin role")
        let unassignAdminRoleEx = expectation(description: "unassign alice admin role")
        let roomDeletedHookEx = expectation(description: "room deleted hook called")
        let deleteRoomEx = expectation(description: "room deleted")

        let onRoomDeleted = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            roomDeletedHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onRoomDeleted: onRoomDeleted)

        assignGlobalRole("admin", toUser: "alice") { err in
            XCTAssertNil(err)
            assignAdminRoleEx.fulfill()
            self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
                XCTAssertNil(err)
                alice!.createRoom(name: "mushroom") { room, err in
                    XCTAssertNil(err)
                    alice!.deleteRoom(id: room!.id) { err in
                        XCTAssertNil(err)
                        deleteRoomEx.fulfill()
                        assignGlobalRole("default", toUser: "alice") { err in
                            XCTAssertNil(err)
                            unassignAdminRoleEx.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testChatManagerRoomUpdatedHookCalled() {
        let assignAdminRoleEx = expectation(description: "assign alice admin role")
        let unassignAdminRoleEx = expectation(description: "unassign alice admin role")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedHookEx = expectation(description: "room updated hook called")
        let updateRoomEx = expectation(description: "room updated")

        let onRoomUpdated = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "balloon")
            XCTAssertFalse(room.isPrivate)
            XCTAssertEqual(room.customData!.keys.count, 2)
            XCTAssertEqual((room.customData!["different"] as! String), "custom stuff")
            XCTAssertEqual(room.customData!["and"] as! [String: String], ["nested": "stuff"])
            roomUpdatedHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(onRoomUpdated: onRoomUpdated)

        assignGlobalRole("admin", toUser: "alice") { err in
            XCTAssertNil(err)
            assignAdminRoleEx.fulfill()
            self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
                XCTAssertNil(err)
                alice!.createRoom(
                    name: "mushroom",
                    isPrivate: true,
                    addUserIDs: ["bob"],
                    customData: ["testing": "some custom data", "and more": 123]
                ) { room, err in
                    XCTAssertNil(err)
                    XCTAssertNotNil(room)
                    XCTAssertEqual(room!.name, "mushroom")
                    XCTAssertTrue(room!.isPrivate)
                    let expectedUserIDs = ["alice", "bob"]
                    let sortedUserIDs = room!.users.map { $0.id }.sorted()
                    XCTAssertEqual(sortedUserIDs, expectedUserIDs)
                    XCTAssertEqual(room!.customData!.keys.count, 2)
                    XCTAssertEqual((room!.customData!["testing"] as! String), "some custom data")
                    XCTAssertEqual(room!.customData!["and more"] as! Int, 123)
                    roomCreatedEx.fulfill()
                    alice!.updateRoom(
                        id: room!.id,
                        name: "balloon",
                        isPrivate: false,
                        customData: ["different": "custom stuff", "and": ["nested": "stuff"]]
                    ) { err in
                        XCTAssertNil(err)
                        updateRoomEx.fulfill()
                        assignGlobalRole("default", toUser: "alice") { err in
                            XCTAssertNil(err)
                            unassignAdminRoleEx.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    // MARK: Room delegate tests

    func testRoomDelegateUserJoinedRoomHookWhenUserJoins() {
        let userJoinedHookEx = expectation(description: "user joined hook called")
        let bobJoinedRoomEx = expectation(description: "bob joined room")

        let onUserJoined = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            userJoinedHookEx.fulfill()
        }

        let aliceRoomDelegate = TestingRoomDelegate(onUserJoined: onUserJoined)

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom") { room, err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    alice!.subscribeToRoom(
                        room: alice!.rooms.first(where: { $0.id == room!.id })!,
                        roomDelegate: aliceRoomDelegate
                    ) { err in
                        XCTAssertNil(err)

                        bob!.joinRoom(id: room!.id) { room, err in
                            XCTAssertNil(err)
                            bobJoinedRoomEx.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testRoomDelegateUserLeftRoomHookWhenUserLeaves() {
        let userLeftHookEx = expectation(description: "user left hook called")
        let bobLeftRoomEx = expectation(description: "bob left room")

        let onUserLeft = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            userLeftHookEx.fulfill()
        }

        let aliceRoomDelegate = TestingRoomDelegate(onUserLeft: onUserLeft)

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIDs: ["bob"]) { room, err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    alice!.subscribeToRoom(
                        room: alice!.rooms.first(where: { $0.id == room!.id })!,
                        roomDelegate: aliceRoomDelegate
                    ) { err in
                        XCTAssertNil(err)

                        bob!.leaveRoom(id: room!.id) { err in
                            XCTAssertNil(err)
                            bobLeftRoomEx.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    // MARK: users property tests

    func testUsersPropertyOfRoomIsProperlyPopulatedAfterSubscribingToRoom() {
        let usersSetProperly = expectation(description: "users property is correct")

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIDs: ["bob"]) { room, err in
                XCTAssertNil(err)

                let roomToTest = alice!.rooms.first(where: { $0.id == room!.id })!

                alice!.subscribeToRoom(
                    room: roomToTest,
                    roomDelegate: TestingRoomDelegate()
                ) { err in
                    XCTAssertNil(err)

                    let expectedUserIDs = ["alice", "bob"]
                    let sortedUserIDs = roomToTest.users.map { $0.id }.sorted()

                    if sortedUserIDs == expectedUserIDs {
                        usersSetProperly.fulfill()
                    } else {
                        XCTFail("Room's users are not set correctly. They were \(sortedUserIDs)")
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }
}
