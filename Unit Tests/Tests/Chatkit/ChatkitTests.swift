import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class ChatkitTests: XCTestCase {
    
    // MARK: - Tests lifecycle
    
    override func tearDown() {
        removeAllStubs()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testShouldSetRequiredConfiguration() {
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider(), logger: TestLogger())
        
//        XCTAssertEqual(chatkit?.instanceLocator, Networking.testInstanceLocator)
//        XCTAssertTrue(chatkit?.tokenProvider is TestTokenProvider)
        XCTAssertTrue(chatkit?.logger is TestLogger)
    }
    
    func testShouldHaveDefaultLogger() {
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        XCTAssertNotNil(chatkit?.logger)
    }
    
    func testShouldNotInstantiateWithInstanceLocatorInIncorrectFormat() {
        let chatkit = try? Chatkit(instanceLocator: "invalidInstanceLocator", tokenProvider: FakeTokenProvider())
        
        XCTAssertNil(chatkit)
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterInstantiation() {
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        XCTAssertEqual(chatkit?.connectionStatus, ConnectionStatus.disconnected)
    }
    
    func testShouldReturnNoErrorAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        let expectation = self.expectation(description: "Connection")
        
        chatkit?.connect { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldReturnErrorAfterUnsuccessfulConnection() {
        // FIXME: This test is disabled in both test schemes due to an issue with handling HTTP status codes in PusherPlatform SDK.
        
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: 404)
        
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        let expectation = self.expectation(description: "Connection")
        
        chatkit?.connect { error in
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldHaveConnectionStatusSetToConnectedAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        let expectation = self.expectation(description: "Connection")
        
        chatkit?.connect { error in
            XCTAssertEqual(chatkit?.connectionStatus, ConnectionStatus.connected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterSuccessfullyDisconnecting() {
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        let expectation = self.expectation(description: "Connection")
        
        chatkit?.connect { _ in
            chatkit?.disconnect()
            
            XCTAssertEqual(chatkit?.connectionStatus, ConnectionStatus.disconnected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterUnsuccessfulConnection() {
        // FIXME: This test is disabled in both test schemes due to an issue with handling HTTP status codes in PusherPlatform SDK.
        
        stubSubscription(of: .chat, version: .version7, instanceLocator: Networking.testInstanceLocator, path: .users, with: 404)
        
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        let expectation = self.expectation(description: "Connection")
        
        chatkit?.connect { _ in
            XCTAssertEqual(chatkit?.connectionStatus, ConnectionStatus.disconnected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
}
