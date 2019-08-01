import Foundation
import PusherPlatform

public class Chatkit {
    
    //MARK: - Properties
    
    public let instanceLocator: String
    public let tokenProvider: PPTokenProvider
    
    //MARK: - Initializers
    
    public init(instanceLocator: String, tokenProvider: PPTokenProvider) {
        self.instanceLocator = instanceLocator
        self.tokenProvider = tokenProvider
    }
    
}
