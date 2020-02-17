import XCTest
@testable import PusherChatkit

import struct PusherPlatform.PPSDKInfo

public class DummySDKInfoProvider: DummyBase, SDKInfoProvider {
    
    public var locator: String {
        DummyFail(sender: self, function: #function)
        return ""
    }

    public var serviceName: String {
        DummyFail(sender: self, function: #function)
        return ""
    }

    public var serviceVersion: String {
        DummyFail(sender: self, function: #function)
        return ""
    }

    public var sdkInfo: PPSDKInfo {
        DummyFail(sender: self, function: #function)
        return PPSDKInfo.current
    }
}
