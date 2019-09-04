import Foundation
import PusherPlatform

protocol Service {
    
    // MARK: - Properties
    
    var name: ServiceName { get }
    var version: ServiceVersion { get }
    
    var connectionStatus: ConnectionStatus { get }
    
    var instance: Instance { get }
    var logger: PPLogger { get }
    
    var delegate: ServiceDelegate? { get }
    
    // MARK: - Initializers
    
    init(instanceLocator: String, client: PPBaseClient, tokenProvider: PPTokenProvider, logger: PPLogger)
    
}

protocol ServiceDelegate: AnyObject {
    
    // MARK: - Methods
    
    func service(_ service: Service, didReceiveEvent event: Event)
    
}
