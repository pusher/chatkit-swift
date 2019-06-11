import XCTest
import PusherPlatform
@testable import PusherChatkit

class ChatManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testInstancesHaveSDKInfoHeadersSet() {
        let chatManager = ChatManager(
            instanceLocator: "v1:test:test",
            tokenProvider: dummyTokenProvider,
            userID: "testinator"
        )

        let sdkProductName = "chatkit"
        let sdkVersion = "1.5.2"
        let sdkLanguage = "swift"

        let baseClientHeadersV2 = chatManager.v2Instance.client.generalRequestURLSession.configuration.httpAdditionalHeaders as! [String: String]
        let baseClientHeadersV3 = chatManager.v4Instance.client.generalRequestURLSession.configuration.httpAdditionalHeaders as! [String: String]

        XCTAssertEqual(baseClientHeadersV2["X-SDK-Product"], sdkProductName)
        XCTAssertEqual(baseClientHeadersV2["X-SDK-Version"], sdkVersion)
        XCTAssertEqual(baseClientHeadersV2["X-SDK-Language"], sdkLanguage)
        
        XCTAssertEqual(baseClientHeadersV3["X-SDK-Product"], sdkProductName)
        XCTAssertEqual(baseClientHeadersV3["X-SDK-Version"], sdkVersion)
        XCTAssertEqual(baseClientHeadersV3["X-SDK-Language"], sdkLanguage)
    }
}

let dummyTokenProvider = PCTokenProvider(url: "https://test.testing/test")
