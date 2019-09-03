import Foundation
import PusherPlatform

class NetworkingController {
    
    // MARK: - Properties
    
    let instanceLocator: String
    let tokenProvider: PPTokenProvider
    let logger: PPLogger
    
    let multipurposeService: MultipurposeService
    
    let client: PPBaseClient
    
    // MARK: - Accessors
    
    var connectionStatus: ConnectionStatus {
        return self.multipurposeService.connectionStatus
    }
    
    // MARK: - Initializers
    
    init(instanceLocator: String, tokenProvider: PPTokenProvider, logger: PPLogger) throws {
        self.instanceLocator = instanceLocator
        self.tokenProvider = tokenProvider
        self.logger = logger
        
        let host = try PPBaseClient.host(for: self.instanceLocator)
        self.client = PPBaseClient(host: host, sdkInfo: PPSDKInfo.current)
        
        self.multipurposeService = MultipurposeService(instanceLocator: self.instanceLocator, client: self.client, tokenProvider: self.tokenProvider, logger: logger)
        self.multipurposeService.delegate = self
    }
    
    // MARK: - Internal methods
    
    func connect() {
        self.multipurposeService.subscribe()
    }
    
    func disconnect() {
        self.multipurposeService.unsubscribe()
    }
    
}

// MARK: - Service delegate

extension NetworkingController: ServiceDelegate {
    
    func service(_ service: Service, didReceiveEvent event: Event) {
    }
    
}
