import Foundation
import PusherPlatform

class FakeTokenProvider: TokenProvider {
    
    // MARK: - Token retrieval
    
    public func fetchToken(completionHandler: @escaping (AuthenticationResult) -> Void) {
        let token = FakeToken()
        completionHandler(.authenticated(token: token))
    }
    
}

// MARK: - Fake token

extension FakeTokenProvider {
    
    struct FakeToken: Token {
        
        // MARK: - Properties
        
        let token: String = "testToken"
        let expiryDate: Date = .distantFuture
        
    }
    
}
