import Foundation
import PusherPlatform

public class PCOnlyForTestingTokenProvider: PPTokenProvider {

    public let userId: String
    let internalTokenProvider: PPHTTPEndpointTokenProvider

    public init(userId: String, serviceId: String) {
        self.userId = userId

        let tokenProvider = PPHTTPEndpointTokenProvider(
            // TODO: NOT THIS URL
            url: "https://boon.ngrok.io/token",
            requestInjector: { req -> PPHTTPEndpointTokenProviderRequest in
                req.addQueryItems(
                    [
                        URLQueryItem(name: "user_id", value: userId),
                        URLQueryItem(name: "service_id", value: serviceId)
                    ]
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
