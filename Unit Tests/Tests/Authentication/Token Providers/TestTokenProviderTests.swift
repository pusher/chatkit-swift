import XCTest
import Mockingjay
@testable import PusherChatkit

class TestTokenProviderTests: XCTestCase {
    
    // MARK: - Properties
    
    var testURL: URL!
    var matcher: (URLRequest) -> Bool = uri("https://instance.pusherplatform.io/services/chatkit_token_provider/test/locator/token?user_id=testUserID")
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        guard let testURL = URL(string: "https://instance.pusherplatform.io/services/chatkit_token_provider/test/locator/token?user_id=testUserID") else {
            preconditionFailure("Failed to instantiate test URL.")
        }
        
        self.testURL = testURL
        self.matcher = uri(self.testURL.absoluteString)
    }
    
    override func tearDown() {
        removeAllStubs()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testShouldInitializeTokenProviderWithCorrectValues() {
        let instanceLocator = Networking.testInstanceLocator
        let userID = Networking.testUserID
        
        XCTAssertNoThrow(try TestTokenProvider(instanceLocator: instanceLocator, userID: userID, logger: TestLogger())) { tokenProvider in
            XCTAssertEqual(tokenProvider.instanceLocator, instanceLocator)
            XCTAssertEqual(tokenProvider.userID, userID)
            XCTAssertTrue(tokenProvider.logger is TestLogger)
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooFewComponents() {
        let instanceLocator = "invalid:locator"
        let userID = Networking.testUserID
        
        XCTAssertThrowsError(try TestTokenProvider(instanceLocator: instanceLocator, userID: userID, logger: TestLogger()), "Failed to catch an error for invalid instance locator.") { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooManyComponents() {
        let instanceLocator = "invalid:test:instance:locator"
        let userID = Networking.testUserID
        
        XCTAssertThrowsError(try TestTokenProvider(instanceLocator: instanceLocator, userID: userID, logger: TestLogger()), "Failed to catch an error for invalid instance locator.") { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldRetrieveTokenFromTestTokenSerivce() {
        stub(self.matcher, jsonFile(named: "token"))
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userID: Networking.testUserID) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        let expectation = self.expectation(description: "Token retrieval")
        
        tokenProvider.fetchToken { result in
            switch result {
            case let .authenticated(token):
                XCTAssertEqual(token.token, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1Nzk2MDQxNDcsImlhdCI6MTU3OTUxNzc0NywiaW5zdGFuY2UiOiI5NzU1MTZmMS1mOWUzLTRlNTUtYTQ0ZC1lNDA3OTIzMmY5NDciLCJpc3MiOiJhcGlfa2V5cy80ZTQyOWNjNS0wM2YzLTQwNzctYmY4ZC04YTcxYWMwYWM2ODgiLCJzdWIiOiJib2IifQ.5uyq_dBsGfdyqnDVDhm7d0R9w6HGApllBLVhwYHCNBI")
                XCTAssertEqual(token.expiryDate.timeIntervalSinceNow, 86400, accuracy: 0.001)
                
            default:
                XCTFail("Failed to retrieve token from the web service.")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldReportAnErrorWhenTokenRetrievalFailed() {
        stub(self.matcher, http(404))
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userID: Networking.testUserID) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        let expectation = self.expectation(description: "Token retrieval")
        
        tokenProvider.fetchToken { result in
            switch result {
            case let .failure(error: error):
                XCTAssertNotNil(error)
            
            default:
                XCTFail("Unexpectedly retrieved token from the web service.")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldSetDefaultContentTypeHeader() {
        stub({ request -> Bool in
            guard let headers = request.allHTTPHeaderFields,
                let contentType = headers["Content-Type"] else {
                    return false
            }
            
            return request.url == self.testURL && contentType == "application/x-www-form-urlencoded"
        }, jsonFile(named: "token"))
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userID: Networking.testUserID) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        let expectation = self.expectation(description: "Token retrieval")
        
        tokenProvider.fetchToken { result in
            switch result {
            case let .authenticated(token):
                XCTAssertNotNil(token)
                
            default:
                XCTFail("Request has not been stubbed due to missing headers.")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testShouldSetDefaultContentTypeBodyItem() {
        stub({ request -> Bool in
            guard let expectedBody = "grant_type=client_credentials".data(using: .utf8),
                let body = request.httpBodyStream?.exhaust() else {
                    return false
            }
            
            return request.url == self.testURL && body == expectedBody
        }, jsonFile(named: "token"))
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userID: Networking.testUserID) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        let expectation = self.expectation(description: "Token retrieval")
        
        tokenProvider.fetchToken { result in
            switch result {
            case let .authenticated(token):
                XCTAssertNotNil(token)
                
            default:
                XCTFail("Request has not been stubbed due to incorrect content of the body.")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
}
