import Foundation
import PusherPlatform

class NetworkingController {
    
    // MARK: - Properties
    
    let instanceLocator: String
    let tokenProvider: TokenProvider
    let logger: PPLogger
    
    let chatService: ChatService
    
    let client: PPBaseClient
    
    // MARK: - Accessors
    
    var connectionStatus: ConnectionStatus {
        return self.chatService.connectionStatus
    }
    
    // MARK: - Initializers
    
    init(instanceLocator: String, tokenProvider: TokenProvider, logger: PPLogger) throws {
        self.instanceLocator = instanceLocator
        self.tokenProvider = tokenProvider
        self.logger = logger
        
        let host = try PPBaseClient.host(for: self.instanceLocator)
        self.client = PPBaseClient(host: host, sdkInfo: PPSDKInfo.current)
        
        self.chatService = ChatService(instanceLocator: self.instanceLocator, client: self.client, tokenProvider: self.tokenProvider, logger: logger)
    }
    
    // MARK: - Internal methods
    
    func connect(completionHandler: CompletionHandler? = nil) {
        self.chatService.subscribe(completionHandler: completionHandler)
    }
    
    func disconnect() {
        self.chatService.unsubscribe()
    }
    
}
