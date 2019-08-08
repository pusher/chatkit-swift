import XCTest
import PusherPlatform
@testable import PusherChatkit

class ChatkitTests: XCTestCase {
    
    //MARK: - Tests
    
    func testShouldSetRequiredConfiguration() {
        let chatkit = try? Chatkit(instanceLocator: "testInstanceLocator", tokenProvider: TestTokenProvider(), logger: PPDefaultLogger())
        
        XCTAssertEqual(chatkit?.instanceLocator, "testInstanceLocator")
        XCTAssertNotNil(chatkit?.tokenProvider)
        XCTAssertNotNil(chatkit?.logger)
    }
    
    func testShouldNotSetLoggerByDefault() {
        let chatkit = try? Chatkit(instanceLocator: "testInstanceLocator", tokenProvider: TestTokenProvider())
        
        XCTAssertNil(chatkit?.logger)
    }
    
}
