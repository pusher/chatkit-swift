import XCTest
import PusherPlatform
@testable import PusherChatkit

class RoomTests: XCTestCase {
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
    }

    func testCreatingARoom() {
        let roomCreatedEx = expectation(description: "room created")

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
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
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testUpdatingARoom() {
        let assignAdminRoleEx = expectation(description: "assign alice admin role")
        let unassignAdminRoleEx = expectation(description: "unassign alice admin role")
        let roomCreatedEx = expectation(description: "room created")
        let roomUpdatedEx = expectation(description: "room updated")
        let roomFetchEx = expectation(description: "updated room fetched")

        assignGlobalRole("admin", toUser: "alice") { err in
            XCTAssertNil(err)
            assignAdminRoleEx.fulfill()

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
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
                        roomUpdatedEx.fulfill()

                        alice!.roomStore.getRoom(id: room!.id) { updatedRoom, err in
                            XCTAssertNil(err)
                            XCTAssertNotNil(updatedRoom)
                            XCTAssertEqual(updatedRoom!.name, "balloon")
                            XCTAssertFalse(updatedRoom!.isPrivate)
                            XCTAssertEqual(updatedRoom!.customData!.keys.count, 2)
                            XCTAssertEqual((updatedRoom!.customData!["different"] as! String), "custom stuff")
                            XCTAssertEqual(updatedRoom!.customData!["and"] as! [String: String], ["nested": "stuff"])
                            roomFetchEx.fulfill()

                            assignGlobalRole("default", toUser: "alice") { err in
                                XCTAssertNil(err)
                                unassignAdminRoleEx.fulfill()
                            }
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testRoomUnreadCounts() {
        let roomCreatedEx = expectation(description: "room created")
        let messageSentEx = expectation(description: "message sent")
        let bobConnectedEx = expectation(description: "room fetched")

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(
                name: "mushroom",
                isPrivate: true,
                addUserIDs: ["bob"],
                customData: ["testing": "some custom data", "and more": 123]
            ) { room, err in
                XCTAssertNil(err)
                XCTAssertNotNil(room)
                roomCreatedEx.fulfill()

                alice!.sendSimpleMessage(roomID: room!.id, text: "test") { _, err in
                    XCTAssertNil(err)
                    messageSentEx.fulfill()
                }

                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
                    XCTAssertNil(err)
                    let bobRoom = bob!.rooms.first(where: { $0.id == room!.id })
                    XCTAssertNotNil(bobRoom)
                    XCTAssertNotNil(bobRoom!.unreadCount)
                    XCTAssertEqual(bobRoom!.unreadCount!, 1)
                    XCTAssertNotNil(bobRoom!.lastMessageAt)
                    bobConnectedEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testRoomUpdatedOnSendingNewMessage() {
        let roomCreatedEx = expectation(description: "room created")
        let messageSentEx = expectation(description: "message sent")
        let roomUpdatedEx = expectation(description: "room updated")

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(
                name: "mushroom",
                isPrivate: true,
                addUserIDs: ["bob"],
                customData: ["testing": "some custom data", "and more": 123]
            ) { room, err in
                XCTAssertNil(err)
                XCTAssertNotNil(room)
                roomCreatedEx.fulfill()

                let onRoomUpdated = { (updatedRoom: PCRoom) in
                    if (updatedRoom.id == room!.id) {
                        XCTAssertNotNil(updatedRoom.unreadCount)
                        XCTAssertEqual(updatedRoom.unreadCount!, 1)
                        XCTAssertNotNil(updatedRoom.lastMessageAt!)
                        roomUpdatedEx.fulfill()
                    }
                }

                let bobCMDelegate = TestingChatManagerDelegate(
                    onRoomUpdated: onRoomUpdated
                )

                self.bobChatManager.connect(delegate: bobCMDelegate) { bob, err in
                    XCTAssertNil(err)
                    alice!.sendSimpleMessage(roomID: room!.id, text: "test") { _, err in
                        XCTAssertNil(err)
                        messageSentEx.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testRoomUpdatedAfterCursorSet() {
        let roomCreatedEx = expectation(description: "room created")
        let bobConnectedEx = expectation(description: "room fetched")
        let roomUpdatedEx = expectation(description: "room updated")
        let cursorSetEx = expectation(description: "cursor set")

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(
                name: "mushroom",
                isPrivate: true,
                addUserIDs: ["bob"],
                customData: ["testing": "some custom data", "and more": 123]
            ) { room, err in
                XCTAssertNil(err)
                XCTAssertNotNil(room)
                roomCreatedEx.fulfill()

                let onRoomUpdated = { (updatedRoom: PCRoom) in
                    if (updatedRoom.id == room!.id) {
                        XCTAssertNotNil(updatedRoom.unreadCount)
                        XCTAssertEqual(updatedRoom.unreadCount!, 0)
                        XCTAssertNotNil(updatedRoom.lastMessageAt!)
                        roomUpdatedEx.fulfill()
                    }
                }

                let bobCMDelegate = TestingChatManagerDelegate(
                    onRoomUpdated: onRoomUpdated
                )

                alice!.sendSimpleMessage(roomID: room!.id, text: "test") { messageID, err in
                    XCTAssertNotNil(messageID)
                    XCTAssertNil(err)

                    self.bobChatManager.connect(delegate: bobCMDelegate) { bob, err in
                        XCTAssertNil(err)
                        let bobRoom = bob!.rooms.first(where: { $0.id == room!.id })
                        XCTAssertNotNil(bobRoom)
                        XCTAssertNotNil(bobRoom!.unreadCount)
                        XCTAssertEqual(bobRoom!.unreadCount!, 1)
                        XCTAssertNotNil(bobRoom!.lastMessageAt)

                        bob!.setReadCursor(position: messageID!, roomID: room!.id) { err in
                            XCTAssertNil(err)
                            cursorSetEx.fulfill()
                        }

                        bobConnectedEx.fulfill()
                    }
                }
            }
        }

        waitForExpectations(timeout: 15)
    }
}
