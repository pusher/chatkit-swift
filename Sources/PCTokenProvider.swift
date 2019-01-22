import Foundation
import PusherPlatform

public final class PCTokenProvider: PPTokenProvider {
    public let url: String
    public let requestInjector: ((PCTokenProviderRequest) -> PCTokenProviderRequest)?
    public var userID: String? = nil {
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

    public var logger: PPLogger? {
        willSet {
            self.internalTokenProvider?.logger = newValue
        }
    }

    let retryStrategy: PCRetryStrategy

    let userIDRequestInjector = { (req: PCTokenProviderRequest, userID: String) -> PCTokenProviderRequest in
        req.addQueryItems([URLQueryItem(name: "user_id", value: userID)])
        return req
    }

    var internalTokenProvider: PCHTTPTokenProvider? = nil

    public init(
        url: String,
        requestInjector: ((PCTokenProviderRequest) -> PCTokenProviderRequest)? = nil,
        retryStrategy: PCRetryStrategy = PCDefaultRetryStrategy()
    ) {
        self.url = url
        self.requestInjector = requestInjector
        self.retryStrategy = retryStrategy
    }

    public func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        queue.async {
            guard !self.fetchingToken else {
                self.logger?.log(
                    "Waiting on existing token fetch request to complete before calling completionHandler",
                    logLevel: .verbose
                )
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

    fileprivate func createInternalTokenProvider() -> PCHTTPTokenProvider {
        let tokenProvider = PCHTTPTokenProvider(
            url: self.url,
            requestInjector: { [weak self] req -> PCTokenProviderRequest in
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
            },
            retryStrategy: self.retryStrategy
        )
        tokenProvider.logger = self.logger

        self.internalTokenProvider = tokenProvider
        return tokenProvider
    }
}
