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
            guard err == nil else {
                fatalError(err!.localizedDescription)
            }
            deleteResourcesEx.fulfill()

            createStandardInstanceRoles() { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createRolesEx.fulfill()
            }

            createUser(id: "alice") { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createAliceEx.fulfill()
            }

            createUser(id: "bob") { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createBobEx.fulfill()
            }

            // TODO the following should really wait until we know both Alice
            // and Bob exist... for now, sleep!
            sleep(1)

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
                    guard err == nil else {
                        fatalError(err!.localizedDescription)
                    }
                    self.roomId = room!.id
                    createRoomEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 10)

        aliceChatManager.disconnect()
    }

    func testChatManagerDelegatePresenceHooks() {
        let onlineEx = expectation(description: "notified of Bob coming online (user)")
        let offlineEx = expectation(description: "notified of Bob going offline (user)")

        let userCameOnline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            onlineEx.fulfill()

            self.bobChatManager.disconnect()
        }

        let userWentOffline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "bob")
            offlineEx.fulfill()
        }

        self.aliceChatManager.connect(delegate: TestingChatManagerDelegate(
            userCameOnline: userCameOnline,
            userWentOffline: userWentOffline
        )) { _, err in
            XCTAssertNil(err)
            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                XCTAssertNil(err)
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testRoomDelegateTypingHooks() {
        let onlineEx = expectation(description: "notified of Alice coming online (room)")
        let offlineEx = expectation(description: "notified of Alice going offline (room)")

        let userCameOnline = { (user: PCUser) -> Void in
            XCTAssertEqual(user.id, "alice")
            onlineEx.fulfill()

            self.bobChatManager.disconnect()
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
            )

            sleep(1) // TODO remove once we can wait on the completion of subscribeToRoom

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                XCTAssertNil(err)
            }
        }

        waitForExpectations(timeout: 15)
    }
}
