import Foundation
import PusherPlatform

/// TestTokenProvider retrieves tokens from the Chatkit service's Test Token Provider, which
/// is for development use only, and must be enabled for your instance in the Chatkit Dashboard.
///
/// The test token provider will always sign a token for the requested userIdentifier, without applying any
/// form of authentication.
public class TestTokenProvider: TokenProvider {
    
    // MARK: - Properties
    
    private static let userIdentifierQueryItemName = "user_id"
    private static let urlScheme = "https"
    private static let urlHost = "pusherplatform.io"
    private static let urlService = "services/chatkit_token_provider"
    private static let urlResource = "token"
    
    private let logger: PPLogger?
    
    private let nestedTokenProvider: DefaultTokenProvider
    
    // MARK: - Initializers
    
    /// Create an TestTokenProvider which retrieves tokens from the Chatkit service's Test Token Provider
    ///
    /// - Parameters:
    ///     - instanceLocator: The locator for your instance, the same value from the Dashboard
    ///     which you use to construct the Chatkit object.
    ///     - userIdentifier: The user identifier for whom to fetch tokens. A token will always
    ///     be signed for this user identifier without any authentication being applied.
    ///     - logger: An optional logger used by the token provider.
    public init(instanceLocator: String, userIdentifier: String, logger: PPLogger? = nil) throws {
        guard let locator = InstanceLocator(string: instanceLocator) else {
            throw ChatkitError.invalidInstanceLocator
        }
        
        let url = try Self.url(for: locator)
        let queryItem = URLQueryItem(name: Self.userIdentifierQueryItemName, value: userIdentifier)
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
        self.nestedTokenProvider.fetchToken(completionHandler: completionHandler)
    }
    
    // MARK: - Private methods
    
    private static func url(for instanceLocator: InstanceLocator) throws -> URL {
        var components = URLComponents()
        components.scheme = Self.urlScheme
        components.host = "\(instanceLocator.region).\(Self.urlHost)"
        components.path = "/\(Self.urlService)/\(instanceLocator.version)/\(instanceLocator.identifier)/\(Self.urlResource)"
        
        guard let url = components.url else {
            throw ChatkitError.invalidInstanceLocator
        }
        
        return url
    }
    
}
