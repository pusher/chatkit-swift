import XCTest
import PusherPlatform
@testable import PusherChatkit

var alice: PCCurrentUser!
var bob: PCCurrentUser!
var roomId: Int!

class AliceRoomDelegate: NSObject, PCRoomDelegate {
    let ex: XCTestExpectation?

    init(expectation: XCTestExpectation? = nil) {
        ex = expectation
    }

    func newCursor(cursor: PCCursor) {
        XCTAssertEqual(cursor.position, 42)
        if let e = ex {
            e.fulfill()
        }
    }
}

class CursorTests: XCTestCase {
    override func setUp() {
        super.setUp()

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")

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
        }

        waitForExpectations(timeout: 10)

        alice = try! connectAsUser(id: "alice")
        bob = try! connectAsUser(id: "bob")

        let room = try! createRoom(
            user: alice,
            roomName: "mushroom",
            addUserIds: ["bob"]
        )

        roomId = room.id
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
            let cursor = try! alice.readCursor(roomId: roomId)
            XCTAssertEqual(cursor?.position, 42)

            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testNewReadCursorHook() {
        let ex = expectation(description: "received new read cursor")

        let aliceRoomDelegate = AliceRoomDelegate(expectation: ex)
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
                let _ = try alice.readCursor(roomId: roomId, userId: "bob")
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

        let aliceRoomDelegate = AliceRoomDelegate()
        alice.subscribeToRoom(
            room: alice.rooms.first(where: { $0.id == roomId })!,
            roomDelegate: aliceRoomDelegate
        )

        sleep(1)

        bob.setReadCursor(position: 42, roomId: roomId) { error in
            XCTAssertNil(error)

            sleep(1) // give the read cursor a chance to propagate down the connection
            let cursor = try! alice.readCursor(roomId: roomId, userId: "bob")
            XCTAssertEqual(cursor?.position, 42)

            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
