import XCTest
@testable import PusherChatkit

class TestTokenProviderTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldRetrieveTokenFromTestTokenSerivce() {
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Environment.instanceLocator, userID: TestUser.joe) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        let expectation = self.expectation(description: "Token retrieval")
        
        tokenProvider.fetchToken { result in
            switch result {
            case let .authenticated(token):
                XCTAssertTrue(token.token.count > 0)
                XCTAssertEqual(token.expiryDate.timeIntervalSinceNow, 86400, accuracy: 0.001)
                
            default:
                XCTFail("Failed to retrieve token from the web service.")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
}
