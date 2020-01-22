import XCTest
@testable import PusherChatkit

import struct PusherPlatform.PPSDKInfo


class DummySDKInfoProvider: DummyBase, SDKInfoProvider {
    var locator: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    var serviceName: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    var serviceVersion: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    var sdkInfo: PPSDKInfo {
        DummyFail(sender: self, function: #function)
        return PPSDKInfo.current
    }
}
