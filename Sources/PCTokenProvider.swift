import Foundation
import PusherPlatform

public final class PCTokenProvider: PPTokenProvider {
    public let url: String
    public let requestInjector: ((PCTokenProviderRequest) -> PCTokenProviderRequest)?
    public var userID: String? = nil

    var fetchingToken: Bool = false
    var queuedTokenRecipients: [(PPTokenProviderResult) -> Void] = []

    let queue = DispatchQueue(label: "com.pusher.chatkit.token-provider")

    public var logger: PPLogger? {
        willSet {
            self.internalTokenProvider.logger = newValue
        }
    }

    let retryStrategy: PCRetryStrategy

    let userIDRequestInjector = { (req: PCTokenProviderRequest, userID: String) -> PCTokenProviderRequest in
        req.addQueryItems([URLQueryItem(name: "user_id", value: userID)])
        return req
    }

    lazy var internalTokenProvider: PCHTTPTokenProvider = {
        return PCHTTPTokenProvider(
            url: url,
            requestInjector: { req -> PCTokenProviderRequest in
                guard let userID = self.userID else {
                    return self.requestInjector != nil ? self.requestInjector!(req) : req
                }

                if let customRequestInjector = self.requestInjector {
                    return self.userIDRequestInjector(customRequestInjector(req), userID)
                }

                return self.userIDRequestInjector(req, userID)
            },
            retryStrategy: retryStrategy
        )
    }()

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

            self.fetchingToken = true

            self.internalTokenProvider.fetchToken { result in
                completionHandler(result)
                self.queuedTokenRecipients.forEach { $0(result) }
                self.queuedTokenRecipients = []
                self.fetchingToken = false
            }
        }
    }
}
