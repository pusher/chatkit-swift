//
//  TokenProvider.swift
//  Chatkit
//
//  Created by Mike Pye on 06/12/2019.
//  Copyright © 2019 Pusher Ltd. All rights reserved.
//
// STUB FILE. This file demonstrates the desired interface, but contains to implementation
// TODO: Move many of these types to PusherPlatform

import Foundation
import PusherPlatform

// TODO: Temporary
extension String: Error { }

// Re-export so that PusherPlatform import is not required in client code
public typealias TokenProvider = PPTokenProvider
public typealias TokenProviderResult = PPTokenProviderResult

/// A factory for `TokenProvider`s.
///
/// The methods on this object create token provider instances which can interface with an HTTP 
/// endpoint in your backend, or the Chatkit Test Token Provider (for use during development)
public struct ChatkitTokenProviders {
    /// Creates a `TokenProvider` which fetches tokens from the Chatkit Test Token Provider. It
    /// should be used for development purposes only.
    ///
    /// The Chatkit Test Token Provider is a token provider endpoint hosted by Pusher which returns
    /// tokens for the requested `userId` without authenticating the user. It is intended for
    /// development convenience and *must not be enabled in instances which host production data*.
    ///
    /// The test token provider must be enabled for your instance in the Chatkit dashboard.
    ///
    /// - Parameters:
    ///     - instanceLocator: The locator string for your instance, which you also provide when
    ///     initialising the `Chatkit` object.
    ///     - userId: The user identifier to fetch a token for. The provider will sign a valid
    ///     token for any user identifier requested, without applying any kind of authentication.
    /// - Returns:a `TokenProvider` which fetches tokens from the Chatkit Test Token Provider.
    public static func createChatkitTestTokenProvider(instanceLocator: String, userId: String) -> TokenProvider {
        return CachingTokenProvider(
            delegateProvider: RetryingTokenProvider(
                delegateProvider: createTestTokenHTTPCallProvider(
                    instanceLocator: instanceLocator, userId: userId
                ),
                retryAttempts: 3,
                retryDelayMs: 1000
            )
        )
    }

    /// Create a `TokenProvider` which fetches tokens from an HTTP endpoint in your backend, with
    /// caching and retry implemented. This is the recommended implementation for production use.
    ///
    /// - Parameters:
    ///     - method: The HTTP method to use in the call, e.g. `GET`, `POST`
    ///     - host: The host name to be called, e.g. `example.com`
    ///     - path: The path component of the URL to be called, e.g. `/tokens`
    ///     - headers: An optional map of headers to include in the request. Here you can supply
    ///     the session or other credientials which your endpoint might require to authenticate the
    ///     request.
    ///     - queryParams: An optional map of query parameters to include in the request URL. Here
    ///     you can supply the session or other credientials which your endpoint might require to
    ///     authenticate the request.
    /// - Returns: a `TokenProvider` which fetches tokens from the specified HTTP endpoint, and is
    /// wrapped in default caching and retry logic.
    public static func createHTTPSTokenProvider(method: String, host: String, path: String, headers: [String: String]?, queryParams: [String: String]?) -> TokenProvider {
        return CachingTokenProvider(
            delegateProvider: RetryingTokenProvider(
                delegateProvider: HTTPCallTokenProvider(
                    method: method,
                    host: host,
                    path: path,
                    headers: headers,
                    queryParams: queryParams
                ),
                retryAttempts: 3,
                retryDelayMs: 1000
            )
        )
    }

    internal static func createTestTokenHTTPCallProvider(instanceLocator: String, userId: String) -> TokenProvider {
        // TODO: Implement:
        // extract host and instanceId from instanceLocator
        let host = "us1.pusherplatform.io"
        let instanceId = "UNIMPLEMENTED"
        let path = "/services/chatkit_token_provider/v1/\(instanceId)/token"

        return HTTPCallTokenProvider(
            method: "POST",
            host: host,
            path: path,
            headers: nil,
            queryParams: [ "user_id": userId ]
        )
    }
}

/// CachingTokenProvider delegates the fetching of tokens to an underlying `delegateProvider`, retrying on failure
public class CachingTokenProvider: TokenProvider {
    private let delegate: TokenProvider
    private var token: String?

    public init(delegateProvider: TokenProvider) {
        self.delegate = delegateProvider
    }

    public func fetchToken(completionHandler: @escaping (TokenProviderResult) -> Void) {
        // TODO: Implement:
        // if token is nil or expired, delegate
        // if call to delegate is in progress, attach to its completion handler
        // return token

        self.delegate.fetchToken(completionHandler: completionHandler)
    }
}

/// RetryingTokenProvider delegates the fetching of tokens to an underlying `delegateProvider`, maintains a reference to the last fetched token and ensures
/// that the delegate is only called when necessary:
public class RetryingTokenProvider: TokenProvider {
    public init(delegateProvider: TokenProvider, retryAttempts: UInt, retryDelayMs: UInt) {}

    public func fetchToken(completionHandler: @escaping (TokenProviderResult) -> Void) {
        // TODO: Implement:
        // fetch token from delegate, with retries on failure
    }
}

/// HTTPCallTokenProvider makes calls to a specified HTTP endpoint and expects to receive a token from it.
///
/// This class will make an HTTP request for every call to `fetchToken`, and in almost all cases it should be wrapped with caching and retry logic. See `httpTokenProvider(...)` for a factory method which returns a wrapped instance of this class.
///
/// - Parameters:
///     - method: The HTTP method to use in the call, e.g. `GET`, `POST`
///     - host: The host name to be called, e.g. `example.com`
///     - path: The path component of the URL to be called, e.g. `/tokens`
///     - headers: An optional map of headers to include in the request. Here you can supply the session or other credientials which your endpoint might require to authenticate the request.
///     - queryParams: An optional map of query parameters to include in the request URL. Here you can supply the session or other credientials which your endpoint might require to authenticate the request.
public class HTTPCallTokenProvider: TokenProvider {
    public init(method: String, host: String, path: String, headers: [String: String]?, queryParams: [String: String]?) {
        // TODO
    }

    public func fetchToken(completionHandler: @escaping (TokenProviderResult) -> Void) {
        completionHandler(TokenProviderResult.error(error: "Unimplemented"))
    }
}
