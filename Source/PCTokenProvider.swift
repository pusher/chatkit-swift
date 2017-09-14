import Foundation
import PusherPlatform

public final class PCTokenProvider: PPTokenProvider {

    public let url: String
    public let userId: String

    let internalTokenProvider: PPHTTPEndpointTokenProvider
    public var logger: PPLogger? {
        willSet {
            self.internalTokenProvider.logger = newValue
        }
    }

    public init(url: String, userId: String) {
        self.url = url
        self.userId = userId

        let tokenProvider = PPHTTPEndpointTokenProvider(
            url: url,
            requestInjector: { req -> PPHTTPEndpointTokenProviderRequest in
                req.addQueryItems(
                    [URLQueryItem(name: "user_id", value: userId)]
                )
                return req
            }
        )

        self.internalTokenProvider = tokenProvider
    }

    public func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        self.internalTokenProvider.fetchToken(completionHandler: completionHandler)
    }
}
