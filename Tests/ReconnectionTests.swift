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

        waitForExpectations(timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
    }

    // MARK: Chat manager delegate tests

    func testAppropriateChatManagerDelegateFunctionsAreCalledWhenReconnectingAndRoomStateHasChanged() {
        let addedToRoomMushroomEx = expectation(description: "added to room mushroom")
        let addedToRoomOldRoomEx = expectation(description: "added to room old room")

        let aliceRemovedEx = expectation(description: "alice removed from old room room")
        let alicedAddedEx = expectation(description: "alice added to new room room")
        let mushroomRoomUpdatedEx = expectation(description: "mushroom room updated")

        let removedFromRoomEx = expectation(description: "removed from room hook called")
        let addedToRoomEx = expectation(description: "added to room hook called")
        let roomUpdatedEx = expectation(description: "room updated hook called")

        let onAddedToRoom = { (room: PCRoom) -> Void in
            switch room.name {
            case "new room":
                addedToRoomEx.fulfill()
            case "old room":
                addedToRoomOldRoomEx.fulfill()
            case "mushroom":
                addedToRoomMushroomEx.fulfill()
            default:
                break
            }
        }

        let onRemovedFromRoom = { (room: PCRoom) -> Void in
            if room.name == "old room" {
                removedFromRoomEx.fulfill()
            }
        }

        let onRoomUpdated = { (room: PCRoom) -> Void in
            if room.name == "new shroom" {
                XCTAssertEqual(room.name, "new shroom")
                XCTAssertTrue(room.isPrivate)
                XCTAssertEqual(room.customData!["hello"] as! String, "world")
                roomUpdatedEx.fulfill()
            }
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRemovedFromRoom: onRemovedFromRoom,
            onRoomUpdated: onRoomUpdated
        )

        var bob: PCCurrentUser!

        let bobsRoomMutationFun = { (roomToUpdateID: String, roomToRemoveFromID: String) -> Void in
            assignGlobalRole("admin", toUser: "bob") { err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { b, err in
                    XCTAssertNil(err)
                    bob = b
                    bob.removeUser(id: "alice", from: roomToRemoveFromID) { err in
                        XCTAssertNil(err)
                        aliceRemovedEx.fulfill()
                    }
                    bob.createRoom(name: "new room", addUserIDs: ["alice"]) { room, err in
                        XCTAssertNil(err)
                        alicedAddedEx.fulfill()
                    }
                    bob.updateRoom(
                        id: roomToUpdateID,
                        name: "new shroom",
                        isPrivate: true,
                        customData: ["hello": "world"]
                    ) { err in
                        XCTAssertNil(err)
                        assignGlobalRole("default", toUser: "bob") { err in
                            XCTAssertNil(err)
                            mushroomRoomUpdatedEx.fulfill()
                        }
                    }
                }
            }
        }

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(name: "mushroom", addUserIDs: ["bob"]) { mushroomRoom, err in
                XCTAssertNil(err)
                alice!.createRoom(name: "old room", addUserIDs: ["bob"]) { oldRoomRoom, err in
                    XCTAssertNil(err)
                    self.wait(for: [addedToRoomMushroomEx, addedToRoomOldRoomEx], timeout: 10)
                    self.aliceChatManager.disconnect()

                    bobsRoomMutationFun(mushroomRoom!.id, oldRoomRoom!.id)
                    self.wait(for: [aliceRemovedEx, alicedAddedEx, mushroomRoomUpdatedEx], timeout: 15)

                    self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
                        XCTAssertNil(err)
                        XCTAssertEqual(alice!.rooms.count, 2, "alice has the wrong number of rooms")
                    }
                }
            }
        }

        wait(for: [removedFromRoomEx, addedToRoomEx, roomUpdatedEx], timeout: 15)
    }

    func testOnRoomUpdateDelegateFunctionIsCalledWhenReconnectingAndARoomsCustomDataHasBeenMutatedBetweenConnections() {
        let addedToRoomMushroomEx = expectation(description: "added to room mushroom")
        let mushroomRoomUpdatedEx = expectation(description: "mushroom room updated")
        let roomUpdatedEx = expectation(description: "room updated hook called")

        let onAddedToRoom = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            addedToRoomMushroomEx.fulfill()
        }

        let onRoomUpdated = { (room: PCRoom) -> Void in
            XCTAssertEqual(room.name, "mushroom")
            XCTAssertFalse(room.isPrivate)
            XCTAssertEqual(room.customData!["new custom data"] as! String, "counts as an update")
            roomUpdatedEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            onAddedToRoom: onAddedToRoom,
            onRoomUpdated: onRoomUpdated
        )

        var bob: PCCurrentUser!

        let bobsRoomMutationFun = { (roomToUpdateID: String) -> Void in
            assignGlobalRole("admin", toUser: "bob") { err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { b, err in
                    XCTAssertNil(err)
                    bob = b
                    bob.updateRoom(
                        id: roomToUpdateID,
                        customData: ["new custom data": "counts as an update"]
                    ) { err in
                        XCTAssertNil(err)
                        assignGlobalRole("default", toUser: "bob") { err in
                            XCTAssertNil(err)
                            mushroomRoomUpdatedEx.fulfill()
                        }
                    }
                }
            }
        }

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.createRoom(
                name: "mushroom",
                addUserIDs: ["bob"],
                customData: ["hello": "world"]
            ) { mushroomRoom, err in
                XCTAssertNil(err)
                self.wait(for: [addedToRoomMushroomEx], timeout: 10)
                self.aliceChatManager.disconnect()

                bobsRoomMutationFun(mushroomRoom!.id)
                self.wait(for: [mushroomRoomUpdatedEx], timeout: 15)

                self.aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
                    XCTAssertNil(err)
                    XCTAssertEqual(alice!.rooms.count, 1, "alice has the wrong number of rooms")
                }
            }
        }

        wait(for: [roomUpdatedEx], timeout: 15)
    }
}
