import Foundation
import PusherPlatform

internal extension PPBaseClient {
    
    // MARK: - Properties
    
    private static let hostname = "pusherplatform.io"
    private static let hostnameSeparator = "."
    private static let instanceLocatorSeparator: Character = ":"
    
    // MARK: - Internal methods
    
    class func host(for instanceLocator: String) throws -> String {
        let components = instanceLocator.split(separator: PPBaseClient.instanceLocatorSeparator)
        
        guard components.count >= 3 else {
            throw NetworkingError.invalidInstanceLocator
        }
        
        let cluster = components[1]
        
        return cluster + PPBaseClient.hostnameSeparator + PPBaseClient.hostname
    }
    
}
