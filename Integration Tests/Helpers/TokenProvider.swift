import Foundation
import PusherPlatform

class TokenProvider: PPTokenProvider {
    
    let url: String
    let requestInjector: ((PPHTTPEndpointTokenProviderRequest) -> PPHTTPEndpointTokenProviderRequest)?
    
    var userID: String? = nil {
        willSet {
            guard newValue != nil else {
                return
            }
            self.pathFriendUserID = pathFriendlyVersion(of: newValue!)
        }
    }
    
    var pathFriendUserID: String? = nil
    var fetchingToken: Bool = false
    var queuedTokenRecipients: [(PPTokenProviderResult) -> Void] = []
    
    let queue = DispatchQueue(label: "com.pusher.chatkit.token-provider")
    
    var logger: PPLogger? {
        willSet {
            self.internalTokenProvider?.logger = newValue
        }
    }
    
    let retryStrategy: PPRetryStrategy
    
    let userIDRequestInjector = { (req: PPHTTPEndpointTokenProviderRequest, userID: String) -> PPHTTPEndpointTokenProviderRequest in
        req.addQueryItems([URLQueryItem(name: "user_id", value: userID)])
        
        return req
    }
    
    var internalTokenProvider: PPHTTPEndpointTokenProvider? = nil
    
    init(url: String, requestInjector: ((PPHTTPEndpointTokenProviderRequest) -> PPHTTPEndpointTokenProviderRequest)? = nil, retryStrategy: PPRetryStrategy = PPDefaultRetryStrategy()) {
        self.url = url
        self.requestInjector = requestInjector
        self.retryStrategy = retryStrategy
    }
    
    func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        queue.async {
            guard !self.fetchingToken else {
                self.logger?.log("Waiting on existing token fetch request to complete before calling completionHandler", logLevel: .verbose)
                self.queuedTokenRecipients.append(completionHandler)
                
                return
            }
            
            let tokenProvider = self.internalTokenProvider ?? self.createInternalTokenProvider()
            
            self.fetchingToken = true
            
            tokenProvider.fetchToken { result in
                completionHandler(result)
                self.queuedTokenRecipients.forEach { $0(result) }
                self.queuedTokenRecipients = []
                self.fetchingToken = false
            }
        }
    }
    
    private func createInternalTokenProvider() -> PPHTTPEndpointTokenProvider {
        let tokenProvider = PPHTTPEndpointTokenProvider(url: self.url, requestInjector: { [weak self] req -> PPHTTPEndpointTokenProviderRequest in
            guard let strongSelf = self else {
                return req
            }
            
            guard let userID = strongSelf.pathFriendUserID else {
                return strongSelf.requestInjector != nil ? strongSelf.requestInjector!(req) : req
            }
            
            if let customRequestInjector = strongSelf.requestInjector {
                return strongSelf.userIDRequestInjector(customRequestInjector(req), userID)
            }
            
            return strongSelf.userIDRequestInjector(req, userID)
            }, retryStrategy: self.retryStrategy)
        
        tokenProvider.logger = self.logger
        
        self.internalTokenProvider = tokenProvider
        
        return tokenProvider
    }
    
    private func pathFriendlyVersion(of component: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        // TODO: When can percent encoding fail?
        return component.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? component
    }
    
}
