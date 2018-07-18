import XCTest
import PusherPlatform
@testable import PusherChatkit

class RoomMembershipTests: XCTestCase {
    var aliceChatManager = newTestChatManager(userId: "alice")
    var bobChatManager = newTestChatManager(userId: "bob")
    var alice: PCCurrentUser!
    var bob: PCCurrentUser!

    override func setUp() {
        super.setUp()

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let connectAliceEx = expectation(description: "connect as Alice")
        let connectBobEx = expectation(description: "connect as Bob")

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
            }

            self.bobChatManager.connect(delegate: TestingChatManagerDelegate()) { user, err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                self.bob = user
                connectBobEx.fulfill()
            }
        }

//        let createRolesEx = expectation(description: "create roles")
//        let createAliceEx = expectation(description: "create Alice")
//        let createBobEx = expectation(description: "create Bob")
//
//        deleteInstanceResources() { err in
//            guard err == nil else {
//                fatalError(err!.localizedDescription)
//            }
//
//            createStandardInstanceRoles() { err in
//                guard err == nil else {
//                    fatalError(err!.localizedDescription)
//                }
//                createRolesEx.fulfill()
//            }
//
//            createUser(id: "alice") { err in
//                guard err == nil else {
//                    fatalError(err!.localizedDescription)
//                }
//                createAliceEx.fulfill()
//            }
//
//            createUser(id: "bob") { err in
//                guard err == nil else {
//                    fatalError(err!.localizedDescription)
//                }
//                createBobEx.fulfill()
//            }
//        }
//
//        bob = try! connectAsUser(id: "bob")

        waitForExpectations(timeout: 10)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        bobChatManager.disconnect()
        alice = nil
        bob = nil
    }

    func testChatManagerUserJoinedRoomHookWhenUserJoins() {
        class AliceCMJoinRoomDelegate: NSObject, PCChatManagerDelegate {
            var ex: XCTestExpectation?
            var userID: String?
            var roomID: Int?

            init(exp: XCTestExpectation? = nil, userID: String? = nil, roomID: Int? = nil) {
                self.ex = exp
                self.userID = userID
                self.roomID = roomID
            }

            func userJoinedRoom(room: PCRoom, user: PCUser) {
                if let e = ex {
                    XCTAssertEqual(user.id, userID)
                    XCTAssertEqual(room.id, roomID)
                    e.fulfill()
                }
            }
        }

        let ex = expectation(description: "user joined room hook called")
        let aliceChatManagerDelegate = AliceCMJoinRoomDelegate(exp: ex, userID: bob.id)
//        alice = try! connectAsUser(id: "alice", delegate: aliceChatManagerDelegate)
//        let room = try! createRoom(user: alice, roomName: "mushroom")
        aliceChatManagerDelegate.roomID = room.id

        let bobJoinedRoomEx = expectation(description: "bob joined room")

        bob.joinRoom(id: room.id) { room, err in
            guard err == nil else {
                XCTFail(err!.localizedDescription)
                return
            }

            bobJoinedRoomEx.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testChatManagerUserLeftRoomHookWhenUserLeaves() {
        class AliceCMLeaveRoomDelegate: NSObject, PCChatManagerDelegate {
            var ex: XCTestExpectation?
            var userID: String?
            var roomID: Int?

            init(exp: XCTestExpectation? = nil, userID: String? = nil, roomID: Int? = nil) {
                self.ex = exp
                self.userID = userID
                self.roomID = roomID
            }

            deinit {
                print("DEINIt AliceCMLeaveRoomDelegate")
            }

            func userLeftRoom(room: PCRoom, user: PCUser) {
                if let e = ex {
                    XCTAssertEqual(user.id, userID)
                    XCTAssertEqual(room.id, roomID)
                    e.fulfill()
                }
            }
        }

        let ex = expectation(description: "user left room hook called")
        let aliceChatManagerDelegate = AliceCMLeaveRoomDelegate(exp: ex, userID: bob.id)
        alice = try! connectAsUser(id: "alice", delegate: aliceChatManagerDelegate)
        let room = try! createRoom(user: alice, roomName: "mushroom", addUserIDs: ["bob"])
        aliceChatManagerDelegate.roomID = room.id

        let bobLeftRoomEx = expectation(description: "bob left room")

        bob.leaveRoom(id: room.id) { err in
            guard err == nil else {
                XCTFail(err!.localizedDescription)
                return
            }

            bobLeftRoomEx.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testChatManagerAddedToRoomHookCalledUserAddedInRoomCreation() {
        class AliceCMAddedToRoomDelegate: NSObject, PCChatManagerDelegate {
            var ex: XCTestExpectation?
            var roomID: Int?

            init(exp: XCTestExpectation? = nil, roomID: Int? = nil) {
                self.ex = exp
                self.roomID = roomID
            }

            deinit {
                print("DEINIt AliceCMAddedToRoomDelegate")
            }

            func addedToRoom(room: PCRoom) {
                if let e = ex {
                    e.fulfill()
                }
            }
        }

        let ex = expectation(description: "added to room hook called when added as part of room creation")
        let aliceChatManagerDelegate = AliceCMAddedToRoomDelegate(exp: ex)
        alice = try! connectAsUser(id: "alice", delegate: aliceChatManagerDelegate)
        let room = try! createRoom(user: bob, roomName: "mushroom", addUserIDs: ["alice"])
        aliceChatManagerDelegate.roomID = room.id

        waitForExpectations(timeout: 10)
    }
}
