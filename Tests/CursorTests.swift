import XCTest
import PusherPlatform
@testable import PusherChatkit

var alice: PCCurrentUser?
var bob: PCCurrentUser?
var roomId: Int?
var doneSetUp = false

class CursorTests: XCTestCase {
    override func setUp() {
        super.setUp()

        if !doneSetUp {
            alice = user(id: "alice")
            bob = user(id: "bob")
            roomId = createRoom(user: user(id: "alice"), roomName: "mushroom", addUserIds: ["bob"]).id
            doneSetUp = true
        }
    }

    func testOwnReadCursorUndefinedIfNotSet() {
        let cursor = try! user(id: "alice").readCursor(roomId: roomId!)
        XCTAssertNil(cursor)
    }

    // TODO own read cursor?

    func testNewReadCursorHook() {
        class AliceRoomDelegate: NSObject, PCRoomDelegate {
            let ex: XCTestExpectation

            init(expectation: XCTestExpectation) {
                ex = expectation
            }

            func newCursor(cursor: PCCursor) {
                XCTAssertEqual(cursor.position, 42)
                ex.fulfill()
            }
        }

        let ex = expectation(description: "received new read cursor")
        let aliceRoomDelegate = AliceRoomDelegate(expectation: ex)
        alice!.subscribeToRoom(
            room: alice!.rooms.first(where: { $0.id == roomId! })!,
            roomDelegate: aliceRoomDelegate
        )

        // TODO can we wait on the subscription to finish (without sleeping...)?
        sleep(2)

        bob?.setReadCursor(position: 42, roomId: roomId!) { error in
            XCTAssertNil(error)
        }

        waitForExpectations(timeout: 50) // why doesn't this work?
    }

    func user(id: String, delegate: PCChatManagerDelegate = TestingChatManagerDelegate()) -> PCCurrentUser {
        var user: PCCurrentUser?

        let ex = expectation(description: "connected as user with ID \(id)")

        let chatManager = ChatManager(
            instanceLocator: testInstanceLocator,
            tokenProvider: PCTokenProvider(url: testInstanceTokenProviderURL),
            userId: id,
            logger: TestLogger()
        )

        chatManager.connect(delegate: delegate) { u, error in
            XCTAssertNil(error)
            XCTAssertNotNil(u)

            user = u
            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
        return user!
    }

    func createRoom(user: PCCurrentUser, roomName: String, addUserIds: [String] = []) -> PCRoom {
        var room: PCRoom?

        let ex = expectation(description: "created room with name  \(roomName)")

        user.createRoom(name: roomName, addUserIds: addUserIds) { r, error in
            XCTAssertNil(error)
            XCTAssertNotNil(r)

            room = r
            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
        return room!
    }
}
