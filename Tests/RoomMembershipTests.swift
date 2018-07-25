import XCTest
import PusherPlatform
@testable import PusherChatkit

class RoomMembershipTests: XCTestCase {
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

            sleep(1)
        }

        waitForExpectations(timeout: 10)
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

        let userJoinedRoom = { (room: PCRoom, user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            XCTAssertEqual(room.name, "mushroom")
            userJoinedRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(userJoinedRoom: userJoinedRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom") { room, err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    bob!.joinRoom(id: room!.id) { room, err in
                        XCTAssertNil(err)
                        bobJoinedRoomEx.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testChatManagerUserLeftRoomHookWhenUserLeaves() {
        let userLeftRoomHookEx = expectation(description: "user left room hook called")
        let bobLeftRoomEx = expectation(description: "bob left room")

        let userLeftRoom = { (room: PCRoom, user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            XCTAssertEqual(room.name, "mushroom")
            userLeftRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(userLeftRoom: userLeftRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    bob!.leaveRoom(id: room!.id) { err in
                        XCTAssertNil(err)
                        bobLeftRoomEx.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testChatManagerAddedToRoomHookCalledWhenSelfAddedInRoomCreation() {
        let addedToRoomHookEx = expectation(description: "added to room hook called when added as part of room creation")

        let addedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(addedToRoom: addedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom") { room, err in
                XCTAssertNil(err)
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testChatManagerAddedToRoomHookCalledWhenUserAddsAnotherUserInRoomCreation() {
        let addedToRoomHookEx = expectation(description: "added to room hook called when added as part of room creation")
        let bobAddAliceEx = expectation(description: "bob added alice to room when creating room")

        let addedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(addedToRoom: addedToRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                XCTAssertNil(err)
                bob!.createRoom(name: "mushroom", addUserIds: ["alice"]) { room, err in
                    XCTAssertNil(err)
                    bobAddAliceEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testChatManagerAddedToRoomHookCalledWhenUserAddsAnotherUser() {
        let addedToRoomHookEx = expectation(description: "added to room hook called")
        let bobAddAliceEx = expectation(description: "bob added alice to room")

        let addedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(addedToRoom: addedToRoom)

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

        waitForExpectations(timeout: 10)
    }

    func testChatManagerRemovedFromRoomHookCalledUserRemovedFromRoom() {
        let removedFromRoomHookEx = expectation(description: "removed from room hook called")
        let bobRemoveAliceEx = expectation(description: "bob removed alice from room")

        let removedFromRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            removedFromRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(removedFromRoom: removedFromRoom)

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
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

        waitForExpectations(timeout: 10)
    }

    func testChatManagerRemovedFromRoomHookCalledUserRemovesSelf() {
        let removedFromRoomHookEx = expectation(description: "removed from room hook called")
        let aliceRemoveSelfEx = expectation(description: "bob removed alice from room")

        let removedFromRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            removedFromRoomHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(removedFromRoom: removedFromRoom)

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

        waitForExpectations(timeout: 10)
    }

    func testChatManagerRoomDeletedHookCalled() {
        let assignAdminRoleEx = expectation(description: "assign alice admin role")
        let unassignAdminRoleEx = expectation(description: "unassign alice admin role")
        let roomDeletedHookEx = expectation(description: "room deleted hook called")
        let deleteRoomEx = expectation(description: "room deleted")

        let roomDeleted = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            roomDeletedHookEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(roomDeleted: roomDeleted)

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

        waitForExpectations(timeout: 10)
    }

    // MARK: Room delegate tests

    func testRoomDelegateUserJoinedRoomHookWhenUserJoins() {
        let userJoinedHookEx = expectation(description: "user joined hook called")
        let bobJoinedRoomEx = expectation(description: "bob joined room")

        let userJoined = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            userJoinedHookEx.fulfill()
        }

        let aliceRoomDelegate = TestingRoomDelegate(userJoined: userJoined)

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

        waitForExpectations(timeout: 10)
    }

    func testRoomDelegateUserLeftRoomHookWhenUserLeaves() {
        let userLeftHookEx = expectation(description: "user left hook called")
        let bobLeftRoomEx = expectation(description: "bob left room")

        let userLeft = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            userLeftHookEx.fulfill()
        }

        let aliceRoomDelegate = TestingRoomDelegate(userLeft: userLeft)

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
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

        waitForExpectations(timeout: 10)
    }

    // MARK: users property tests

    func testUsersPropertyOfRoomIsProperlyPopulatedAfterSubscribingToRoom() {
        let usersSetProperly = expectation(description: "users property is correct")

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
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

        waitForExpectations(timeout: 10)
    }
}
