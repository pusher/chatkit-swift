import XCTest
@testable import PusherChatkit

class ChatkitTests: XCTestCase {
    
    //MARK: - Tests
    
    func testConfiguration() {
        
        let testTokenProvider = TestTokenProvider()
        let chatkit = Chatkit(instanceLocator: "testInstanceLocator", tokenProvider: testTokenProvider)
        
        XCTAssertEqual(chatkit.instanceLocator, "testInstanceLocator")
        XCTAssertNotNil(chatkit.tokenProvider as? TestTokenProvider)
    }
    
}
