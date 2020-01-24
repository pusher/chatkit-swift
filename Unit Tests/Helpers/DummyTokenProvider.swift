import Foundation
import PusherPlatform

class DummyTokenProvider: TokenProvider {
    
    // MARK: - Token retrieval
    
    public func fetchToken(completionHandler: @escaping (AuthenticationResult) -> Void) {
        let token = DummyToken()
        completionHandler(.authenticated(token: token))
    }
    
}

// MARK: - Dummy token

extension DummyTokenProvider {
    
    struct DummyToken: Token {
        
        // MARK: - Properties
        
        let token: String = "testToken"
        let expiryDate: Date = .distantFuture
        
    }
    
}
