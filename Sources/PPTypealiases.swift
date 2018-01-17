import Foundation
import PusherPlatform

public typealias PCHTTPTokenProvider = PPHTTPEndpointTokenProvider
public typealias PCTokenProviderRequest = PPHTTPEndpointTokenProviderRequest
public typealias PCLogger = PPLogger
public typealias PCLogLevel = PPLogLevel
public typealias PCDefaultLogger = PPDefaultLogger
public typealias PCDownloadFileDestination = PPDownloadFileDestination
public typealias PCDownloadOptions = PPDownloadOptions
public typealias PCRetryStrategy = PPRetryStrategy
public typealias PCDefaultRetryStrategy = PPDefaultRetryStrategy


public func PCSuggestedDownloadDestination(
    for directory: FileManager.SearchPathDirectory = .documentDirectory,
    in domain: FileManager.SearchPathDomainMask = .userDomainMask,
    options: PPDownloadOptions = []
) -> PCDownloadFileDestination {
    return PPSuggestedDownloadDestination(for: directory, in: domain, options: options)
}
