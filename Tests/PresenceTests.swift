import XCTest
import PusherPlatform
@testable import PusherChatkit

class PresenceTests: XCTestCase {
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

            // TODO the following should really wait until we know both Alice
            // and Bob exist... for now, sleep!
            sleep(1)

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
                XCTAssertNil(err)
                alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
                    XCTAssertNil(err)
                    self.roomId = room!.id
                    self.aliceChatManager.disconnect()
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

    func testChatManagerDelegatePresenceHooks() {
        sleep(2) // FIXME this is a disgrace

        let onlineEx = expectation(description: "notified of Bob coming online (user)")
        let offlineEx = expectation(description: "notified of Bob going offline (user)")

        let userCameOnline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            onlineEx.fulfill()

            sleep(2) // TODO this shouldn't be necessary.
            self.bobChatManager.disconnect()
        }

        let userWentOffline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            offlineEx.fulfill()
        }

        let aliceCMDelegate = TestingChatManagerDelegate(
            userCameOnline: userCameOnline,
            userWentOffline: userWentOffline
        )

        self.aliceChatManager.connect(delegate: aliceCMDelegate) { u, err in
            XCTAssertNil(err)
            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                XCTAssertNil(err)
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testRoomDelegatePresenceHooks() {
        sleep(2) // FIXME this is a disgrace

        let onlineEx = expectation(description: "notified of Alice coming online (room)")
        let offlineEx = expectation(description: "notified of Alice going offline (room)")

        let userCameOnline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "alice")
            onlineEx.fulfill()

            sleep(2) // TODO this shouldn't be necessary.
            self.aliceChatManager.disconnect()
        }

        let userWentOffline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "alice")
            offlineEx.fulfill()
        }

        let bobRoomDelegate = TestingRoomDelegate(
            userCameOnline: userCameOnline,
            userWentOffline: userWentOffline
        )

        self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)
            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
                roomDelegate: bobRoomDelegate
            ) { err in
                XCTAssertNil(err)

                self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                    XCTAssertNil(err)
                }
            }
        }

        waitForExpectations(timeout: 10)
    }
}
