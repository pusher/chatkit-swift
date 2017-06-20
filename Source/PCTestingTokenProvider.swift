import Foundation
import PusherPlatform

public class PCTestingTokenProvider: PPTokenProvider {

    public let url: String
    public let userId: String
    public let serviceId: String
    public var retryStrategy: PPRetryStrategy
    public var logger: PPLogger? = nil {
        willSet {
            (self.retryStrategy as? PPDefaultRetryStrategy)?.logger = newValue
        }
    }

    public var accessToken: String? = nil
    public var refreshToken: String? = nil
    public internal(set) var accessTokenExpiresAt: Double? = nil

    public init(userId: String, serviceId: String) {
        self.url = "https://chat-api-test-token-provider.herokuapp.com/token"
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

    public func fetchTokenAndUserId(completionHandler: @escaping (PCTokenAndUserIdRequestResult) -> Void) {

        // TODO: [unowned self] ?

        let retryAwareCompletionHandler = { (tokenProviderResult: PCTokenAndUserIdRequestResult) in
            switch tokenProviderResult {
            case .error(let err):
                let shouldRetryResult = self.retryStrategy.shouldRetry(given: err)

                switch shouldRetryResult {
                case .retry(let retryWaitTimeInterval):
                    // TODO: [unowned self] here as well?

                    DispatchQueue.main.asyncAfter(deadline: .now() + retryWaitTimeInterval, execute: { [unowned self] in
                        self.fetchTokenAndUserId(completionHandler: completionHandler)
                    })
                case .doNotRetry(let reasonErr):
                    completionHandler(PCTokenAndUserIdRequestResult.error(error: reasonErr))
                }
                return
            case .success(let userId):
                self.retryStrategy.requestSucceeded()
                completionHandler(PCTokenAndUserIdRequestResult.success(userId: userId))
            }
        }

        makeRequestForTokenAndUserId(completionHandler: retryAwareCompletionHandler)
    }

    fileprivate func getTokenPair(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        makeRequestForToken(grantType: PPEndpointRequestGrantType.clientCredentials, completionHandler: completionHandler)
    }

    fileprivate func refreshAccessToken(completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        makeRequestForToken(grantType: PPEndpointRequestGrantType.refreshToken, completionHandler: completionHandler)
    }

    fileprivate func makeRequestForToken(grantType: PPEndpointRequestGrantType, completionHandler: @escaping (PPTokenProviderResult) -> Void) {
        let authRequestResult = prepareAuthRequest(grantType: grantType)

        guard let request = authRequestResult.request, authRequestResult.error == nil else {
            completionHandler(PPTokenProviderResult.error(error: authRequestResult.error!))
            return
        }

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, sessionError in
            do {
                let tokenProviderResponse = try self.validateCompletionValues(data: data, response: response, sessionError: sessionError)

                self.accessToken = tokenProviderResponse.accessToken
                self.refreshToken = tokenProviderResponse.refreshToken
                self.accessTokenExpiresAt = Date().timeIntervalSince1970 + tokenProviderResponse.expiresIn

                completionHandler(PPTokenProviderResult.success(token: tokenProviderResponse.accessToken))
            } catch let err {
                self.logger?.log(err.localizedDescription, logLevel: .verbose)
                completionHandler(PPTokenProviderResult.error(error: err))
            }
        }).resume()
    }

    fileprivate func makeRequestForTokenAndUserId(completionHandler: @escaping (PCTokenAndUserIdRequestResult) -> Void) {
        let authRequestResult = prepareAuthRequest(grantType: .clientCredentials)

        guard let request = authRequestResult.request, authRequestResult.error == nil else {
            completionHandler(PCTokenAndUserIdRequestResult.error(error: authRequestResult.error!))
            return
        }

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, sessionError in
            do {
                let tokenProviderResponse = try self.validateCompletionValues(data: data, response: response, sessionError: sessionError)

                guard let userId = tokenProviderResponse.responseJSON["user_id"] as? String else {
                    completionHandler(
                        PCTokenAndUserIdRequestResult.error(
                            error: PCOnlyForTestingTokenProviderError.validUserIdNotPresentInResponseJSON(tokenProviderResponse.responseJSON)
                        )
                    )
                    return
                }

                self.accessToken = tokenProviderResponse.accessToken
                self.refreshToken = tokenProviderResponse.refreshToken
                self.accessTokenExpiresAt = Date().timeIntervalSince1970 + tokenProviderResponse.expiresIn

                completionHandler(PCTokenAndUserIdRequestResult.success(userId: userId))
            } catch let err {
                self.logger?.log(err.localizedDescription, logLevel: .verbose)
                completionHandler(PCTokenAndUserIdRequestResult.error(error: err))
            }
        }).resume()
    }


    fileprivate func validateCompletionValues(data: Data?, response: URLResponse?, sessionError: Error?) throws -> PCTestingTokenProviderResponse {
        if let error = sessionError {
            throw error
        }

        guard let data = data else {
            throw PPHTTPEndpointTokenProviderError.noDataPresent
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PPHTTPEndpointTokenProviderError.invalidHTTPResponse(response: response, data: data)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw PPHTTPEndpointTokenProviderError.badResponseStatusCode(response: httpResponse, data: data)
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw PPHTTPEndpointTokenProviderError.failedToDeserializeJSON(data)
        }

        guard let json = jsonObject as? [String: Any] else {
            throw PPHTTPEndpointTokenProviderError.failedToCastJSONObjectToDictionary(jsonObject)
        }

        guard let accessToken = json["access_token"] as? String else {
            throw PPHTTPEndpointTokenProviderError.validAccessTokenNotPresentInResponseJSON(json)
        }

        guard let refreshToken = json["refresh_token"] as? String else {
            throw PPHTTPEndpointTokenProviderError.validRefreshTokenNotPresentInResponseJSON(json)
        }

        // TODO: Check if Double is sensible type here
        guard let expiresIn = json["expires_in"] as? TimeInterval else {
            throw PPHTTPEndpointTokenProviderError.validExpiresInNotPresentInResponseJSON(json)
        }

        return PCTestingTokenProviderResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            responseJSON: json
        )
    }

    fileprivate func prepareAuthRequest(grantType: PPEndpointRequestGrantType) -> (request: URLRequest?, error: Error?) {
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

public struct PCTestingTokenProviderResponse {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
    let responseJSON: [String: Any]
}

public enum PCTokenAndUserIdRequestResult {
    case success(userId: String)
    case error(error: Error)
}

public enum PCOnlyForTestingTokenProviderError: Error {
    case validUserIdNotPresentInResponseJSON([String: Any])
}
