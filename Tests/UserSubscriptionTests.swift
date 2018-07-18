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
            createUser(id: "ash") { err in
                guard err == nil else {
                    fatalError(err!.localizedDescription)
                }
                createUserEx.fulfill()
            }
        }

        waitForExpectations(timeout: 10)
    }

    override func tearDown() {
        super.tearDown()
        chatManager.disconnect()
    }

    func testThatWeCanConnect() {
        let tokenEndpoint = testInstanceTokenProviderURL

        chatManager = ChatManager(
            instanceLocator: testInstanceLocator,
            tokenProvider: PCTokenProvider(url: tokenEndpoint),
            userId: "ash",
            logger: TestLogger()
        )

        let ex = expectation(description: "Get currentUser back when connecting")

        chatManager.connect(delegate: TestingChatManagerDelegate()) { currentUser, error in
            XCTAssertNil(error)
            XCTAssertNotNil(currentUser)
            ex.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
