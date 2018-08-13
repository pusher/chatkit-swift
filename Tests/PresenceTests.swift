import XCTest
import PusherPlatform
@testable import PusherChatkit

class PresenceTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var charlieChatManager: ChatManager!
    var roomID: Int!

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
        charlieChatManager = newTestChatManager(userID: "charlie")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createCharlieEx = expectation(description: "create Charlie")
        let createRoomEx = expectation(description: "create room")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()

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

            // TODO the following should really wait until we know Alice, Bob,
            // and Charlie exist... for now, sleep!
            sleep(1)

            self.charlieChatManager.connect(delegate: TestingChatManagerDelegate()) { charlie, err in
                XCTAssertNil(err)

                charlie!.createRoom(
                    name: "mushroom",
                    addUserIDs: [self.uniqueAlice, self.uniqueBob]
                ) { room, err in
                    XCTAssertNil(err)
                    self.roomID = room!.id
                    self.charlieChatManager.disconnect()
                    createRoomEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
        charlieChatManager.disconnect()
        charlieChatManager = nil
        roomID = nil
    }

    func testChatManagerDelegatePresenceHooks() {
        let initialPresenceEx = expectation(description: "notified of Bob initially being offline (user)")
        let onlineEx = expectation(description: "notified of Bob coming online (user)")
        let offlineEx = expectation(description: "notified of Bob going offline (user)")

        let userPresenceChanged = { (previous: PCPresenceState, current: PCPresenceState, user: PCUser) -> Void in
            guard user.id != "charlie" else { return }
            XCTAssertEqual(user.id, self.uniqueBob)

            if case .unknown = previous, case .offline = current {
                initialPresenceEx.fulfill()
            } else if case .offline = previous, case .online = current {
                onlineEx.fulfill()
                self.bobChatManager.disconnect()
            } else if case .online = previous, case .offline = current {
                offlineEx.fulfill()
            }
        }

        let aliceCMDelegate = TestingChatManagerDelegate(userPresenceChanged: userPresenceChanged)

        aliceChatManager.connect(delegate: aliceCMDelegate) { alice, err in
            XCTAssertNil(err)
            alice!.subscribeToRoom(
                room: alice!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: TestingRoomDelegate()
            ) { err in
                XCTAssertNil(err)
                self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { _, err in
                    XCTAssertNil(err)
                }
            }
        }

        waitForExpectations(timeout: 15)
    }
}
