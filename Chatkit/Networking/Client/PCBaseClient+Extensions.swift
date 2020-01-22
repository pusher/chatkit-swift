import Foundation
import PusherPlatform

internal extension PPBaseClient {
    
    // MARK: - Properties
    
    private static let hostname = "pusherplatform.io"
    private static let separator = "."
    
    // MARK: - Internal methods
    
    class func host(for instanceLocator: String) throws -> String {
        let locator = try InstanceLocator(instanceLocator)
        return [locator.region, PPBaseClient.hostname].joined(separator: PPBaseClient.separator)
    }
    
}
