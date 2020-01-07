import Foundation
import PusherPlatform

// FIXME: Temporary
extension String: Error { }

public typealias TokenProvider = PPTokenProvider
public typealias TokenProviderResult = PPTokenProviderResult

public typealias AsyncKeyValueCall = (CredentialsCompletionHandler) -> Void
public typealias CredentialsCompletionHandler = (KeyValueResult) -> Void

public enum KeyValueResult {
    
    case success([String: String])
    case error(Error)
    
}
