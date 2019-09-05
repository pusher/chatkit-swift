import Foundation
import PusherPlatform

internal extension PPSDKInfo {
    
    // MARK: - Properties
    
    private static let productName = "chatkit"
    private static let unknownVersion = "unknown"
    
    static let current: PPSDKInfo = PPSDKInfo(productName: PPSDKInfo.productName,
                                              sdkVersion: Bundle.current.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? PPSDKInfo.unknownVersion)
    
}
