import XCTest
import PusherPlatform
import Environment
@testable import PusherChatkit

class TestTokenProviderTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldRetrieveTokenFromTestTokenService() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        guard let tokenProvider = try? TestTokenProvider(instanceLocator: Environment.instanceLocator, userIdentifier: TestUser.joe) else {
            preconditionFailure("Failed to instantiate test token provider.")
        }
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let expectation = self.expectation(description: "Token retrieval")
        var result: AuthenticationResult?
        
        tokenProvider.fetchToken { authenticationResult in
            result = authenticationResult
            expectation.fulfill()
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: 5.0)
        
        guard case let .authenticated(token: token) = result else {
            XCTFail("Failed to retrieve token from the web service.")
            return
        }
        
        XCTAssertTrue(token.value.count > 0)
        XCTAssertEqual(token.expiryDate.timeIntervalSinceNow, 86400, accuracy: 0.01)
    }
    
}
