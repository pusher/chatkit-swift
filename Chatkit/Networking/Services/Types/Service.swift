import Foundation
import PusherPlatform

protocol Service {
    
    // MARK: - Properties
    
    var name: ServiceName { get }
    
    var connectionStatus: ConnectionStatus { get }
    
    var logger: PPLogger { get }
    
    // MARK: - Initializers
    
    init(instanceLocator: String, client: PPBaseClient, tokenProvider: PPTokenProvider, logger: PPLogger)
    
}
