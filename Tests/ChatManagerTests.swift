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
            userId: "testinator"
        )

        let sdkProductName = "chatkit"
        let sdkVersion = "0.7.0"
        let sdkLanguage = "swift"

        let baseClientHeaders = chatManager.instance.client.generalRequestURLSession.configuration.httpAdditionalHeaders as! [String: String]

        XCTAssertEqual(baseClientHeaders["X-SDK-Product"], sdkProductName)
        XCTAssertEqual(baseClientHeaders["X-SDK-Version"], sdkVersion)
        XCTAssertEqual(baseClientHeaders["X-SDK-Language"], sdkLanguage)
    }
}

let dummyTokenProvider = PCTokenProvider(url: "https://test.testing/test")
