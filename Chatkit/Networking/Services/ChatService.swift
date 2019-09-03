import Foundation
import PusherPlatform

class ChatService: Service {
    
    // MARK: - Properties
    
    let instance: Instance
    let logger: PPLogger
    
    weak var delegate: ServiceDelegate?
    
    private let requestOptions: PPRequestOptions
    private var resumableSubscription: PPResumableSubscription
    
    // MARK: - Accessors
    
    var connectionStatus: ConnectionStatus {
        switch self.resumableSubscription.state {
        case .open:
            return .connected
            
        case .resuming:
            return .connecting
            
        default:
            return .disconnected
        }
    }
    
    // MARK: - Initializers
    
    required init(instanceLocator: String, client: PPBaseClient, tokenProvider: PPTokenProvider, logger: PPLogger) {
        self.logger = logger
        self.instance = Instance(locator: instanceLocator,
                                 serviceName: ServiceName.chat.rawValue,
                                 serviceVersion: ServiceVersion.version6.rawValue,
                                 client: client,
                                 tokenProvider: tokenProvider,
                                 logger: self.logger)
        self.requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: "/users")
        self.resumableSubscription = PPResumableSubscription(instance: self.instance, requestOptions: self.requestOptions)
    }
    
    // MARK: - Internal methods
    
    func subscribe(completionHandler: CompletionHandler? = nil) {
        self.instance.subscribeWithResume(with: &self.resumableSubscription, using: self.requestOptions, onOpen: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.resumableSubscription.onOpen = nil
            self.resumableSubscription.onError = nil
            
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
        }, onEvent: { [weak self] _, _, jsonObject in
            guard let self = self, let event = Event(with: jsonObject) else {
                return
            }
            
            self.delegate?.service(self, didReceiveEvent: event)
        }, onError: { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.logger.log("Chat service subscription failed with error: \(error.localizedDescription)", logLevel: .warning)
            
            self.resumableSubscription.onOpen = nil
            self.resumableSubscription.onError = nil
            self.resumableSubscription.end()
            
            if let completionHandler = completionHandler {
                completionHandler(error)
            }
        })
    }
    
    func unsubscribe() {
        self.resumableSubscription.end()
    }
    
}
