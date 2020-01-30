import struct PusherPlatform.PPSDKInfo

protocol HasSDKInfoProvider {
    var sdkInfoProvider: SDKInfoProvider { get }
}

protocol SDKInfoProvider {
    var serviceName: String { get }
    var serviceVersion: String { get }
    var sdkInfo: PPSDKInfo { get }
}

struct ConcreteSDKInfoProvider: SDKInfoProvider {
    let serviceName: String
    let serviceVersion: String
    let sdkInfo: PPSDKInfo
}
