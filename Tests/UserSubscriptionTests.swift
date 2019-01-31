import XCTest
import PusherPlatform
@testable import PusherChatkit

class UserSubscriptionTests: XCTestCase {
    var chatManager: ChatManager!

    override func setUp() {
        super.setUp()

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createUserEx = expectation(description: "create user")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()
        }
        wait(for: [deleteResourcesEx], timeout: 15)

        createStandardInstanceRoles() { err in
            XCTAssertNil(err)
            createRolesEx.fulfill()
        }

        createUser(id: "ash") { err in
            XCTAssertNil(err)
            createUserEx.fulfill()
        }
        wait(for: [createRolesEx, createUserEx], timeout: 15)
    }

    override func tearDown() {
        super.tearDown()
        chatManager.disconnect()
        chatManager = nil
    }

    func testThatWeCanConnect() {
        chatManager = newTestChatManager(userID: "ash")
        let ex = expectation(description: "Get currentUser back when connecting")

        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            ex.fulfill()
        }

        waitForExpectations(timeout: 15)
    }
}
