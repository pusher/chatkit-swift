import Foundation
import PusherPlatform

public final class PCTokenProvider: PPTokenProvider {

    public let userId: String
    public let url: String

    let internalTokenProvider: PPHTTPEndpointTokenProvider
    public var logger: PPLogger? {
        willSet {
            self.internalTokenProvider.logger = newValue
        }
    }

    public init(userId: String, url: String) {
        self.userId = userId
        self.url = url

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
