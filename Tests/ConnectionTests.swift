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
}
