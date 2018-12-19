import XCTest
import PusherPlatform
#if os(iOS) || os(macOS)
import BeamsChatkit
#endif
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
        let sdkVersion = "1.2.2"
        let sdkLanguage = "swift"

        let baseClientHeaders = chatManager.instance.client.generalRequestURLSession.configuration.httpAdditionalHeaders as! [String: String]

        XCTAssertEqual(baseClientHeaders["X-SDK-Product"], sdkProductName)
        XCTAssertEqual(baseClientHeaders["X-SDK-Version"], sdkVersion)
        XCTAssertEqual(baseClientHeaders["X-SDK-Language"], sdkLanguage)
    }
}

let dummyTokenProvider = PCTokenProvider(url: "https://test.testing/test")
