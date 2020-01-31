import TestUtilities
import XCTest
@testable import PusherChatkit

class ChatkitTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldSetRequiredConfiguration() {
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider(), logger: TestLogger())
        
        XCTAssertTrue(chatkit?.logger is TestLogger)
    }
    
    func testShouldHaveDefaultLogger() {
        let chatkit = try? Chatkit(instanceLocator: Networking.testInstanceLocator, tokenProvider: FakeTokenProvider())
        
        XCTAssertNotNil(chatkit?.logger)
    }
    
    func testShouldNotInstantiateWithInstanceLocatorInIncorrectFormat() {
        let chatkit = try? Chatkit(instanceLocator: "invalidInstanceLocator", tokenProvider: FakeTokenProvider())
        
        XCTAssertNil(chatkit)
    }
    
}
