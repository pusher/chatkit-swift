import Foundation
import PusherPlatform

public typealias PCTokenProviderRequest = PPHTTPEndpointTokenProviderRequest

public final class PCTokenProvider: PPTokenProvider {
    public let url: String
    public let userId: String?

    let internalTokenProvider: PPHTTPEndpointTokenProvider
    public var logger: PPLogger? {
        willSet {
            self.internalTokenProvider.logger = newValue
        }
    }

    public init(url: String, userId: String? = nil, requestInjector: ((PCTokenProviderRequest) -> PCTokenProviderRequest)? = nil) {
        self.url = url
        self.userId = userId

        let userIdRequestInjector = { (req: PCTokenProviderRequest) -> PCTokenProviderRequest in
            req.addQueryItems(
                [URLQueryItem(name: "user_id", value: userId)]
            )
            return req
        }

        let tokenProvider = PPHTTPEndpointTokenProvider(
            url: url,
            requestInjector: { req -> PCTokenProviderRequest in
                if let customRequestInjector = requestInjector {
                    return userIdRequestInjector(customRequestInjector(req))
                }

                return userIdRequestInjector(req)
            }
        )

        self.internalTokenProvider = tokenProvider
    }

    public func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        self.internalTokenProvider.fetchToken(completionHandler: completionHandler)
    }
}
