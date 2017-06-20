import Foundation
import PusherPlatform

public class PCOnlyForTestingTokenProvider: PPTokenProvider {

    public let url: String
    public let userId: String
    public let serviceId: String
    public var retryStrategy: PPRetryStrategy

    public var accessToken: String? = nil
    public var refreshToken: String? = nil
    public internal(set) var accessTokenExpiresAt: Double? = nil

    public init(userId: String, serviceId: String) {

        // TODO: Shouldn't be using this url

        self.url = "https://boon.ngrok.io/token"
        self.userId = userId
        self.serviceId = serviceId
        self.retryStrategy = PPDefaultRetryStrategy()
    }

    public func fetchToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {

        // TODO: [unowned self] ?

        let retryAwareCompletionHandler = { (tokenProviderResult: PPTokenProviderResult) in
            switch tokenProviderResult {
            case .error(let err):
                let shouldRetryResult = self.retryStrategy.shouldRetry(given: err)

                switch shouldRetryResult {
                case .retry(let retryWaitTimeInterval):
                    // TODO: [unowned self] here as well?

                    DispatchQueue.main.asyncAfter(deadline: .now() + retryWaitTimeInterval, execute: { [unowned self] in
                        self.fetchToken(completionHandler: completionHandler)
                    })
                case .doNotRetry(let reasonErr):
                    completionHandler(PPTokenProviderResult.error(error: reasonErr))
                }
                return
            case .success(let token):
                self.retryStrategy.requestSucceeded()
                completionHandler(PPTokenProviderResult.success(token: token))
            }
        }

        if let token = self.accessToken, let tokenExpiryTime = self.accessTokenExpiresAt {
            guard tokenExpiryTime > Date().timeIntervalSince1970 else {
                if self.refreshToken != nil {
                    refreshAccessToken(completionHandler: retryAwareCompletionHandler)
                } else {
                    getTokenPair(completionHandler: retryAwareCompletionHandler)
                }
                // TODO: Is returning here correct?
                return
            }
            completionHandler(PPTokenProviderResult.success(token: token))
        } else {
            getTokenPair(completionHandler: retryAwareCompletionHandler)
        }
    }

    public func getTokenPair(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        makeAuthRequest(grantType: PPEndpointRequestGrantType.clientCredentials, completionHandler: completionHandler)
    }

    public func refreshAccessToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        makeAuthRequest(grantType: PPEndpointRequestGrantType.refreshToken, completionHandler: completionHandler)
    }

    public func makeAuthRequest(grantType: PPEndpointRequestGrantType, completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        let authRequestResult = prepareAuthRequest(grantType: grantType)

        guard let request = authRequestResult.request, authRequestResult.error == nil else {
            completionHandler(PPTokenProviderResult.error(error: authRequestResult.error!))
            return
        }

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, sessionError in
            if let error = sessionError {
                completionHandler(PPTokenProviderResult.error(error: error))
                return
            }

            guard let data = data else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.noDataPresent))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.invalidHTTPResponse(response: response, data: data)))
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.badResponseStatusCode(response: httpResponse, data: data)))
                return
            }

            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.failedToDeserializeJSON(data)))
                return
            }

            guard let json = jsonObject as? [String: Any] else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.failedToCastJSONObjectToDictionary(jsonObject)))
                return
            }

            guard let accessToken = json["access_token"] as? String else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.validAccessTokenNotPresentInResponseJSON(json)))
                return
            }

            guard let refreshToken = json["refresh_token"] as? String else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.validRefreshTokenNotPresentInResponseJSON(json)))
                return
            }

            // TODO: Check if Double is sensible type here
            guard let expiresIn = json["expires_in"] as? TimeInterval else {
                completionHandler(PPTokenProviderResult.error(error: PPHTTPEndpointTokenProviderError.validExpiresInNotPresentInResponseJSON(json)))
                return
            }

            guard let userId = json["user_id"] as? String else {
                completionHandler(PPTokenProviderResult.error(error: PCOnlyForTestingTokenProviderError.validUserIdNotPresentInResponseJSON(json)))
                return
            }

            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.accessTokenExpiresAt = Date().timeIntervalSince1970 + expiresIn

            completionHandler(PPTokenProviderResult.success(token: accessToken))
        }).resume()
    }

    public func prepareAuthRequest(grantType: PPEndpointRequestGrantType) -> (request: URLRequest?, error: Error?) {
        guard var endpointURLComponents = URLComponents(string: self.url) else {
            return (request: nil, error: PPHTTPEndpointTokenProviderError.failedToCreateURLComponents(self.url))
        }

        let grantBodyString = "grant_type=\(grantType.rawValue)"

        endpointURLComponents.queryItems = [
            URLQueryItem(name: "user_id", value: self.userId),
            URLQueryItem(name: "service_id", value: self.serviceId)
        ]

        guard let endpointURL = endpointURLComponents.url else {
            return (request: nil, error: PPHTTPEndpointTokenProviderError.failedToCreateURLObject(endpointURLComponents))
        }

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = grantBodyString.data(using: .utf8)

        return (request: request, error: nil)
    }

}

public enum PCOnlyForTestingTokenProviderError: Error {
    case validUserIdNotPresentInResponseJSON([String: Any])
}
