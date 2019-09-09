import XCTest
import Mockingjay
import PusherPlatform
@testable import PusherChatkit

class ChatServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    var client: PPBaseClient!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        guard let host = try? PPBaseClient.host(for: Networking.testInstanceLocator) else {
            assertionFailure("Failed to determine host.")
            return
        }
        
        self.client = PPBaseClient(host: host, sdkInfo: PPSDKInfo.current)
    }
    
    override func tearDown() {
        removeAllStubs()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testShouldSetRequiredConfiguration() {
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        XCTAssertEqual(service.name, ServiceName.chat)
        XCTAssertEqual(service.version, ServiceVersion.version6)
        XCTAssertTrue(service.logger is TestLogger)
    }
    
    func testShouldNotHaveDelegateAfterInstantiation() {
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        XCTAssertNil(service.delegate)
    }
    
    func testShouldSetDelegate() {
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let delegate = TestServiceDelegate()
        service.delegate = delegate
        
        XCTAssertNotNil(service.delegate)
    }
    
    func testShouldHaveConnectionStatusSetToDisconnectedAfterInstantiation() {
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        XCTAssertEqual(service.connectionStatus, ConnectionStatus.disconnected)
    }
    
    func testShouldReturnNoErrorAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version6, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        service.subscribe() { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldReturnErrorAfterUnsuccessfulConnection() {
        // FIXME: This test is disabled in both test schemes due to an issue with handling HTTP status codes in PusherPlatform SDK.
        
        stubSubscription(of: .chat, version: .version6, instanceLocator: Networking.testInstanceLocator, path: .users, with: 404)
        
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        service.subscribe() { error in
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldHaveConnectionStatusSetToConnectedAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version6, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        service.subscribe() { error in
            XCTAssertEqual(service.connectionStatus, ConnectionStatus.connected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldBeHaveConnectionStatusSetToDisconnectedAfterSuccessfullyDisconnecting() {
        stubSubscription(of: .chat, version: .version6, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        service.subscribe() { error in
            service.unsubscribe()
            
            XCTAssertEqual(service.connectionStatus, ConnectionStatus.disconnected)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldBeHaveConnectionStatusSetToDisconnectedAfterUnsuccessfulConnection() {
        // FIXME: This test is disabled in both test schemes due to an issue with handling HTTP status codes in PusherPlatform SDK.
        
        stubSubscription(of: .chat, version: .version6, instanceLocator: Networking.testInstanceLocator, path: .users, with: 404)
        
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let expectation = self.expectation(description: "Connection")
        
        service.subscribe() { error in
            XCTAssertEqual(service.connectionStatus, ConnectionStatus.disconnected)
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldReceiveInitialStateEventAfterSuccessfulConnection() {
        stubSubscription(of: .chat, version: .version6, instanceLocator: Networking.testInstanceLocator, path: .users, with: "chat-initial_state")
        
        let service = ChatService(instanceLocator: Networking.testInstanceLocator, client: self.client, tokenProvider: TestTokenProvider(), logger: TestLogger())
        
        let eventExpectation = self.expectation(description: "Event")
        
        let delegate = TestServiceDelegate { event in
            XCTAssertNotNil(event)
            XCTAssertEqual(event.name, Event.Name.initialState)
            
            eventExpectation.fulfill()
        }
        service.delegate = delegate
        
        let connectionExpectation = self.expectation(description: "Connection")
        
        service.subscribe() { error in
            connectionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
}
