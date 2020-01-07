import Foundation

/// HTTPCallTokenProvider makes calls to a specified HTTPS endpoint and expects to receive a token
/// from it.
///
/// This is the implementation we recommend for production use, to request tokens from your backend
/// system.
///
/// If this class does not fit your needs, you can implement the `TokenProvider` protocol yourself.
public class DefaultTokenProvider: TokenProvider {
    
    private let method: String
    private let host: String
    private let path: String
    private let getHeaders: AsyncKeyValueCall?
    private let getQueryParams: AsyncKeyValueCall?
    
    /// Create an DefaultTokenProvider which presents either headers or query parameters as part of
    /// the request. These should be used to identify your application user session to your backend
    /// so that it can issue a token for the user.
    ///
    /// - Parameters:
    ///     - method: The HTTP method to use in the call, e.g. `POST`
    ///     - host: The host name to be called, e.g. `example.com`
    ///     - path: The path component of the URL to be called, e.g. `/tokens`
    ///     - headers: An optional map of headers to include in the request. Here you can supply
    ///     the session or other credientials which your endpoint might require to authenticate
    ///     the request.
    ///     - queryParams: An optional map of query parameters to include in the request URL.
    ///     Here you can supply any query parameters which your endpoint might require to process
    ///     the request.
    public convenience init(method: String, host: String, path: String, headers: [String: String]? = nil, queryParams: [String: String]? = nil) {
        self.init(method: method,
                  host: host,
                  path: path,
                  getHeaders: DefaultTokenProvider.wrapCredentialsValue(headers),
                  getQueryParams: DefaultTokenProvider.wrapCredentialsValue(queryParams))
    }
    
    /// Create an DefaultTokenProvider which presents either headers or query parameters as part of
    /// the request. These should be used to identify your application user session to your backend
    /// so that it can issue a token for the user.
    ///
    /// - Parameters:
    ///     - method: The HTTP method to use in the call, e.g. `POST`
    ///     - host: The host name to be called, e.g. `example.com`
    ///     - path: The path component of the URL to be called, e.g. `/tokens`
    ///     - headers: An optional async function which will be invoked when a request is about
    ///     to be made, so that you can supply headers describing the current application user
    ///     session.
    ///     - queryParams: An optional async function which will be invoked when a request is about
    ///     to be made, so that you can supply query parameters which your backend might require
    ///     to process the request.
    public init(method: String, host: String, path: String, getHeaders: AsyncKeyValueCall? = nil, getQueryParams: AsyncKeyValueCall? = nil) {
        self.method = method
        self.host = host
        self.path = path
        self.getHeaders = getHeaders
        self.getQueryParams = getQueryParams
    }
    
    public func fetchToken(completionHandler: @escaping (TokenProviderResult) -> Void) {
        completionHandler(TokenProviderResult.error(error: "Unimplemented"))
    }
    
    private static func wrapCredentialsValue(_ literal: [String: String]?) -> AsyncKeyValueCall? {
        guard let literal = literal else {
            return nil
        }
        
        return { completionHandler in
            return completionHandler(KeyValueResult.success(literal))
        }
    }
    
}
