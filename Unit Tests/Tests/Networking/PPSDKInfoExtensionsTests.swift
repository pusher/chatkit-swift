import XCTest
import PusherPlatform
@testable import PusherChatkit

class PPSDKInfoExtensionsTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCurrentSDKInfo() {
        XCTAssertNotNil(PPSDKInfo.current)
    }

    // FIXME: Uncomment this test after changing access level of PPSDKInfo properties in PusherPlatform SDK.
//    func testCurrentSDKInfoShouldHaveProductNameSetToChatkit() {
//        let sdkInfo = PPSDKInfo.current
//
//        XCTAssertEqual(sdkInfo.productName, "chatkit")
//    }
    
    // FIXME: Uncomment this test after changing access level of PPSDKInfo properties in PusherPlatform SDK.
//    func testCurrentSDKInfoShouldHaveSDKVersionSetToCurrentVersionOfFramework() {
//        let sdkInfo = PPSDKInfo.current
//
//        let bundle = Bundle.current
//
//        guard let expectedVersion = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
//            assertionFailure("Failed to read version number of the SDK.")
//            return
//        }
//
//        XCTAssertEqual(sdkInfo.sdkVersion, expectedVersion)
//    }
    
}
