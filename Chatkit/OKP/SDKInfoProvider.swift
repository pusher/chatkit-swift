import struct PusherPlatform.PPSDKInfo

protocol HasSDKInfoProvider {
    var sdkInfoProvider: SDKInfoProvider { get }
}

protocol SDKInfoProvider {
    var locator: String { get }
    var serviceName: String { get }
    var serviceVersion: String { get }
    var sdkInfo: PPSDKInfo { get }
}

struct ConcreteSDKInfoProvider: SDKInfoProvider {
    let locator: String
    let serviceName: String
    let serviceVersion: String
    let sdkInfo: PPSDKInfo
}












