import Foundation
import PusherPlatform

class MultipurposeService: Service {
    
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
            
        case .opening, .resuming:
            return .connecting
            
        default:
            return .disconnected
        }
    }
    
    // MARK: - Initializers
    
    required init(instanceLocator: String, client: PPBaseClient, tokenProvider: PPTokenProvider, logger: PPLogger) {
        self.logger = logger
        self.instance = Instance(locator: instanceLocator,
                                 serviceName: ServiceName.multipurpose.rawValue,
                                 serviceVersion: ServiceVersion.version6.rawValue,
                                 client: client,
                                 tokenProvider: tokenProvider,
                                 logger: self.logger)
        self.requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: "/users")
        self.resumableSubscription = PPResumableSubscription(instance: self.instance, requestOptions: self.requestOptions)
    }
    
    // MARK: - Internal methods
    
    func subscribe() {
        self.instance.subscribeWithResume(with: &self.resumableSubscription, using: self.requestOptions, onEvent: { [weak self] _, _, jsonObject in
            guard let self = self, let event = Event(with: jsonObject) else {
                return
            }
            
            self.delegate?.service(self, didReceiveEvent: event)
        }, onError: { [weak self] error in
            guard let self = self else {
                return
            }
            
            self.logger.log("Multipurpose service subscription failed with error: \(error.localizedDescription)", logLevel: .warning)
        })
    }
    
    func unsubscribe() {
        self.resumableSubscription.end()
    }
    
}
