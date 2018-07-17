import XCTest
import PusherPlatform
@testable import PusherChatkit

class CursorTests: XCTestCase {
    var aliceChatManager = newTestChatManager(userId: "alice")
    var bobChatManager = newTestChatManager(userId: "bob")
    var alice: PCCurrentUser!
    var bob: PCCurrentUser!
    var roomId: Int!

    override func setUp() {
        super.setUp()

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let connectAliceEx = expectation(description: "connect as Alice")
        let connectBobEx = expectation(description: "connect as Bob")
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

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { user, err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                self.alice = user
                connectAliceEx.fulfill()

                self.alice.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
                    guard err == nil else {
                        fatalError(err!.localizedDescription)
                    }
                    self.roomId = room!.id
                    createRoomEx.fulfill()
                }
            }

            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { user, err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                self.bob = user
                connectBobEx.fulfill()
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testOwnReadCursorUndefinedIfNotSet() {
        let cursor = try! alice.readCursor(roomId: roomId)
        XCTAssertNil(cursor)
    }

    // TODO hook for setting own read cursor? (currently unsupported by the looks of it)

    func testGetOwnReadCursor() {
        let ex = expectation(description: "got own read cursor")

        alice.setReadCursor(position: 42, roomId: roomId) { error in
            XCTAssertNil(error)

            sleep(1) // give the read cursor a chance to propagate down the connection
            let cursor = try! self.alice.readCursor(roomId: self.roomId)
            XCTAssertEqual(cursor?.position, 42)

            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testNewReadCursorHook() {
        let ex = expectation(description: "received new read cursor")

        let newCursor = { (cursor: PCCursor) -> Void in
            XCTAssertEqual(cursor.position, 42)
            ex.fulfill()
        }

        let aliceRoomDelegate = TestingRoomDelegate(newCursor: newCursor)

        alice.subscribeToRoom(
            room: alice.rooms.first(where: { $0.id == roomId })!,
            roomDelegate: aliceRoomDelegate
        )

        sleep(1) // TODO remove once we can wait on the completion of subscribeToRoom

        bob.setReadCursor(position: 42, roomId: roomId) { error in
            XCTAssertNil(error)
        }

        waitForExpectations(timeout: 5)
    }

    func testGetAnotherUsersReadCursorBeforeSubscribingFails() {
        let ex = expectation(description: "get another users read cursor fails")

        bob.setReadCursor(position: 42, roomId: roomId) { error in
            XCTAssertNil(error)

            do {
                let _ = try self.alice.readCursor(roomId: self.roomId, userId: "bob")
            } catch let error {
                switch error {
                case PCCurrentUserError.noSubscriptionToRoom:
                    ex.fulfill()
                default:
                    XCTFail()
                }
            }
        }

        waitForExpectations(timeout: 5)
    }

    func testGetAnotherUsersReadCursor() {
        let ex = expectation(description: "got another users read cursor")

        let aliceRoomDelegate = TestingRoomDelegate()
        alice.subscribeToRoom(
            room: alice.rooms.first(where: { $0.id == roomId })!,
            roomDelegate: aliceRoomDelegate
        )

        sleep(1)

        bob.setReadCursor(position: 42, roomId: roomId) { error in
            XCTAssertNil(error)

            sleep(1) // give the read cursor a chance to propagate down the connection
            let cursor = try! self.alice.readCursor(roomId: self.roomId, userId: "bob")
            XCTAssertEqual(cursor?.position, 42)

            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
