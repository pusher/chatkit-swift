import Foundation
import PusherPlatform

/// TestTokenProvider retrieves tokens from the Chatkit service's Test Token Provider, which
/// is for development user only, and must be enabled for your instance in the Chatkit Dashboard.
///
/// The test token provider will always sign a token for the requested userID, without applying any
/// form of authentication.
public class TestTokenProvider: TokenProvider {
    
    // MARK: - Properties
    
    private static let userIdentifierQueryItemName = "user_id"
    private static let urlScheme = "https"
    private static let urlHost = "pusherplatform.io"
    private static let urlService = "services/chatkit_token_provider"
    private static let urlResource = "token"
    
    /// The locator for your instance, the same value from the Dashboard which you use to construct
    /// the Chatkit object.
    public let instanceLocator: String
    
    /// The userID to fetch tokens for. A token will always be signed for this userID without any
    /// authentication being applied.
    public let userID: String
    
    /// An optional logger used by the token provider.
    public let logger: PPLogger?
    
    private let nestedTokenProvider: DefaultTokenProvider
    
    // MARK: - Initializers
    
    /// - Parameters:
    ///     - instanceLocator: The locator for your instance, the same value from the Dashboard
    ///     which you use to construct the Chatkit object.
    ///     - userID: The userID to fetch tokens for. A token will always be signed for this userID
    ///     without any authentication being applied.
    ///     - logger: An optional logger used by the token provider.
    public init(instanceLocator: String, userID: String, logger: PPLogger? = nil) throws {
        self.instanceLocator = instanceLocator
        self.userID = userID
        
        let locator = try InstanceLocator(instanceLocator)
        let url = try TestTokenProvider.url(for: locator)
        let queryItem = URLQueryItem(name: TestTokenProvider.userIdentifierQueryItemName, value: userID)
        self.nestedTokenProvider = DefaultTokenProvider(url: url, queryItems: [queryItem], logger: logger)
        
        self.logger = logger
    }
    
    // MARK: - Token retrieval
    
    /// Method called by the SDK to authenticate the user.
    ///
    /// - Parameters:
    ///     - completionHandler: The completion handler that provides
    ///     `AuthenticationResult` to the SDK.
    public func fetchToken(completionHandler: @escaping (AuthenticationResult) -> Void) {
//        self.nestedTokenProvider.fetchToken(completionHandler: completionHandler)
        self.nestedTokenProvider.fetchToken { result in
            completionHandler(result)
        }
    }
    
    // MARK: - Private methods
    
    private static func url(for instanceLocator: InstanceLocator) throws -> URL {
        var components = URLComponents()
        components.scheme = TestTokenProvider.urlScheme
        components.host = "\(instanceLocator.region).\(TestTokenProvider.urlHost)"
        components.path = "/\(TestTokenProvider.urlService)/\(instanceLocator.version)/\(instanceLocator.identifier)/\(TestTokenProvider.urlResource)"
        
        guard let url = components.url else {
            throw NetworkingError.invalidInstanceLocator
        }
        
        return url
    }
    
}
