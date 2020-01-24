import XCTest
import Mockingjay
import PusherPlatform
@testable import PusherChatkit

class TestTokenProviderTests: XCTestCase {
    
    // MARK: - Properties
    
    var testURL: URL!
    var matcher: ((URLRequest) -> Bool)!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        guard let testURL = URL(string: "https://instance.pusherplatform.io/services/chatkit_token_provider/test/locator/token?user_id=testUserIdentifier") else {
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
        let userID = Networking.testUserIdentifier
        
        XCTAssertNoThrow(try TestTokenProvider(instanceLocator: instanceLocator, userIdentifier: userID, logger: TestLogger())) { tokenProvider in
            XCTAssertNotNil(tokenProvider)
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooFewComponents() {
        let instanceLocator = "invalid:locator"
        let userID = Networking.testUserIdentifier
        
        XCTAssertThrowsError(try TestTokenProvider(instanceLocator: instanceLocator, userIdentifier: userID, logger: TestLogger()), "Failed to catch an error for invalid instance locator.") { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldThrowErrorForInstanceLocatorWithTooManyComponents() {
        let instanceLocator = "invalid:test:instance:locator"
        let userID = Networking.testUserIdentifier
        
        XCTAssertThrowsError(try TestTokenProvider(instanceLocator: instanceLocator, userIdentifier: userID, logger: TestLogger()), "Failed to catch an error for invalid instance locator.") { error in
            XCTAssertEqual(error as? NetworkingError, NetworkingError.invalidInstanceLocator)
        }
    }
    
    func testShouldRetrieveTokenFromTestTokenSerivce() {
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userIdentifier: Networking.testUserIdentifier) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stub(self.matcher, jsonFile(named: "token"))
        
        let expectation = self.expectation(description: "Token retrieval")
        var result: AuthenticationResult?
        
        tokenProvider.fetchToken { authenticationResult in
            result = authenticationResult
            expectation.fulfill()
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        waitForExpectations(timeout: 1.0)
        
        guard case let .authenticated(token: token) = result else {
            XCTFail("Failed to retrieve token from the web service.")
            return
        }
        
        XCTAssertEqual(token.token, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1Nzk2MDQxNDcsImlhdCI6MTU3OTUxNzc0NywiaW5zdGFuY2UiOiI5NzU1MTZmMS1mOWUzLTRlNTUtYTQ0ZC1lNDA3OTIzMmY5NDciLCJpc3MiOiJhcGlfa2V5cy80ZTQyOWNjNS0wM2YzLTQwNzctYmY4ZC04YTcxYWMwYWM2ODgiLCJzdWIiOiJib2IifQ.5uyq_dBsGfdyqnDVDhm7d0R9w6HGApllBLVhwYHCNBI")
        XCTAssertEqual(token.expiryDate.timeIntervalSinceNow, 86400, accuracy: 0.001)
    }
    
    func testShouldReportAnErrorWhenTokenRetrievalFailed() {
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userIdentifier: Networking.testUserIdentifier) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stub(self.matcher, http(404))
        
        let expectation = self.expectation(description: "Token retrieval")
        var result: AuthenticationResult?
        
        tokenProvider.fetchToken { authenticationResult in
            result = authenticationResult
            expectation.fulfill()
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        waitForExpectations(timeout: 1.0)
        
        guard case let .failure(error: error) = result else {
            XCTFail("Unexpectedly retrieved token from the web service.")
            return
        }
        
        XCTAssertNotNil(error)
    }
    
    func testShouldSetDefaultContentTypeHeader() {
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userIdentifier: Networking.testUserIdentifier) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stub({ request -> Bool in
            guard let headers = request.allHTTPHeaderFields,
                let contentType = headers["Content-Type"] else {
                    return false
            }
            
            return request.url == self.testURL && contentType == "application/x-www-form-urlencoded"
        }, jsonFile(named: "token"))
        
        let expectation = self.expectation(description: "Token retrieval")
        var result: AuthenticationResult?
        
        tokenProvider.fetchToken { authenticationResult in
            result = authenticationResult
            expectation.fulfill()
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        waitForExpectations(timeout: 1.0)
        
        guard case let .authenticated(token: token) = result else {
            XCTFail("Request has not been stubbed due to missing headers.")
            return
        }
        
        XCTAssertGreaterThan(token.token.count, 0)
    }
    
    func testShouldSetDefaultContentTypeBodyItem() {
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Networking.testInstanceLocator, userIdentifier: Networking.testUserIdentifier) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stub({ request -> Bool in
            guard let expectedBody = "grant_type=client_credentials".data(using: .utf8),
                let body = request.httpBodyStream?.exhaust() else {
                    return false
            }
            
            return request.url == self.testURL && body == expectedBody
        }, jsonFile(named: "token"))
        
        let expectation = self.expectation(description: "Token retrieval")
        var result: AuthenticationResult?
        
        tokenProvider.fetchToken { authenticationResult in
            result = authenticationResult
            expectation.fulfill()
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        waitForExpectations(timeout: 1.0)
        
        guard case let .authenticated(token: token) = result else {
            XCTFail("Request has not been stubbed due to incorrect content of the body.")
            return
        }
        
        XCTAssertGreaterThan(token.token.count, 0)
    }
    
}
