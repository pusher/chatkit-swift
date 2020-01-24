import XCTest
@testable import PusherChatkit

class NetworkingControllerTests: XCTestCase {
    
    // MARK: - Tests lifecycle
    
    override func tearDown() {
        removeAllStubs()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testShouldSetRequiredConfiguration() {
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        XCTAssertEqual(networkingController?.instanceLocator, Networking.testInstanceLocator)
        XCTAssertTrue(networkingController?.tokenProvider is DummyTokenProvider)
        XCTAssertTrue(networkingController?.logger is TestLogger)
    }
    
    func testShouldNotThrowErrorWhenInstantiatingWithInstanceLocatorInCorrectFormat() {
        XCTAssertNoThrow(try NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                  tokenProvider: DummyTokenProvider(),
                                                  logger: TestLogger()), "Failed to instantiate NetworkingController without an error.")
    }
    
    func testShouldThrowErrorWhenInstantiatingWithInstanceLocatorInIncorrectFormat() {
        XCTAssertThrowsError(try NetworkingController(instanceLocator: "invalidInstanceLocator",
                                                      tokenProvider: DummyTokenProvider(),
                                                      logger: TestLogger()),
                             "Failed to catch an error for invalid instance locator.") { error in
                                guard let error = error as? NetworkingError else {
                                    return
                                }
                                
                                XCTAssertEqual(error, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterInstantiation() {
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        XCTAssertEqual(networkingController?.connectionStatus, ConnectionStatus.disconnected)
    }
    
    func testShouldReturnNoErrorAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        networkingController?.connect { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldReturnErrorAfterUnsuccessfulConnection() {
        // FIXME: This test is disabled in both test schemes due to an issue with handling HTTP status codes in PusherPlatform SDK.
        
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: 404)
        
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        networkingController?.connect { error in
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }

    func testShouldHaveConnectionStatusSetToConnectedAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        networkingController?.connect { error in
            XCTAssertEqual(networkingController?.connectionStatus, ConnectionStatus.connected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterSuccessfullyDisconnecting() {
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        networkingController?.connect { _ in
            networkingController?.disconnect()
            
            XCTAssertEqual(networkingController?.connectionStatus, ConnectionStatus.disconnected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterUnsuccessfulConnection() {
        // FIXME: This test is disabled in both test schemes due to an issue with handling HTTP status codes in PusherPlatform SDK.
        
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: 404)
        
        let networkingController = try? NetworkingController(instanceLocator: Networking.testInstanceLocator,
                                                             tokenProvider: DummyTokenProvider(),
                                                             logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        networkingController?.connect { _ in
            XCTAssertEqual(networkingController?.connectionStatus, ConnectionStatus.disconnected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
}
