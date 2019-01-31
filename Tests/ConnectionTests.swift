import XCTest
@testable import PusherChatkit

class ConnectionTests: XCTestCase {

    override func setUp() {
        super.setUp()

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()
        }

        wait(for: [deleteResourcesEx], timeout: 15)

        createStandardInstanceRoles() { err in
            XCTAssertNil(err)
            createRolesEx.fulfill()
        }

        wait(for: [createRolesEx], timeout: 15)
    }

    func testConnectionWorksWithWeirdUserIDs() {
        let usersCreatedEx = expectation(description: "users created")

        let weirdUserIDs = [
            "user id with spaces",
            "ⓤⓢⓔⓡ①",
            "ЦƧΣЯ1",
            "u҉s҉e҉r҉1҉",
            // emoji
            "🧘emojizen",
            // Combining diacritics (é)
            "e\u{0301}",
            // Modified emoji (e.g. skin tones)
            "🙆🏽",
            "with/slash",
            "addaboy++",
            "email@email.email"
        ]

        var connectionExpectations = [XCTestExpectation]()

        let userIDsToExpectations = weirdUserIDs.reduce(into: [String: XCTestExpectation]()) { res, id in
            let exp = expectation(description: "\(id) connected successfully")
            connectionExpectations.append(exp)
            res[id] = exp
        }
        let usersToCreate = weirdUserIDs.map { ["id": $0, "name": $0] }

        createUsers(users: usersToCreate) { err in
            XCTAssertNil(err)
            usersCreatedEx.fulfill()
        }

        wait(for: [usersCreatedEx], timeout: 20)

        var chatManagers = [ChatManager]()

        weirdUserIDs.forEach { id in
            let chatManager = newTestChatManager(userID: id)
            chatManagers.append(chatManager)
            chatManager.connect(delegate: TestingChatManagerDelegate()) { cUser, err in
                XCTAssertNil(err)
                XCTAssertEqual(cUser!.id, id)
                userIDsToExpectations[id]!.fulfill()
            }
        }

        wait(for: connectionExpectations, timeout: 30)
    }

    func testConnectionWorksWhenCurrentUserReceivesAReadCursorForADeletedRoom() {
        let userCreatedEx = expectation(description: "alice created")
        let roomCreatedEx = expectation(description: "room created")
        let roomDeletedEx = expectation(description: "room deleted")
        let readCursorSetEx = expectation(description: "read cursor set")
        let connectedEx = expectation(description: "alice connected")

        let userID = "alice"

        createUser(id: userID) { err in
            XCTAssertNil(err)
            userCreatedEx.fulfill()
        }
        wait(for: [userCreatedEx], timeout: 15)

        var roomID: String!

        createRoom(creatorID: userID, name: "test room") { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            roomID = roomIDFromJSON

            roomCreatedEx.fulfill()
        }
        wait(for: [roomCreatedEx], timeout: 15)

        deleteRoom(id: roomID) { err in
            XCTAssertNil(err)
            roomDeletedEx.fulfill()
        }
        wait(for: [roomDeletedEx], timeout: 15)

        setReadCursor(
            userID: userID,
            roomID: roomID,
            position: 100
        ) { err in
            XCTAssertNil(err)
            readCursorSetEx.fulfill()
        }
        wait(for: [readCursorSetEx], timeout: 15)

        let aliceChatManager = newTestChatManager(userID: userID)

        aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
            XCTAssertNil(err)
            XCTAssertEqual(alice!.cursorStore.cursors.keys.count, 0)
            connectedEx.fulfill()
        }

        wait(for: [connectedEx], timeout: 15)
    }
}
