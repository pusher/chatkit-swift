import Foundation

/// TestTokenProvider retrieves tokens from the Chatkit service's Test Token Provider, which
/// is for development user only, and must be enabled for your instance in the Chatkit Dashboard.
///
/// The test token provider will always sign a token for the requested userID, without applying any
/// form of authentication.
public class TestTokenProvider: TokenProvider {
    
    private let delegate: DefaultTokenProvider
    
    /// - Parameters:
    ///     - instanceLocator: The locator for your instance, the same value from the Dashboard
    ///     which you use to construct the Chatkit object.
    ///     - userID: The userID to fetch tokens for. A token will always be signed for this userID
    ///     without any authentication being applied.
    init(instanceLocator: String, userID: String) {
        // TODO: Implement:
        // extract host and instanceId from instanceLocator
        let host = "us1.pusherplatform.io"
        let instanceId = "UNIMPLEMENTED"
        let path = "/services/chatkit_token_provider/v1/\(instanceId)/token"
        
        self.delegate = DefaultTokenProvider(method: "POST", host: host, path: path, headers: nil, queryParams: ["user_id": userID])
    }
    
    public func fetchToken(completionHandler: @escaping (TokenProviderResult) -> Void) {
        self.delegate.fetchToken(completionHandler: completionHandler)
    }
    
}
