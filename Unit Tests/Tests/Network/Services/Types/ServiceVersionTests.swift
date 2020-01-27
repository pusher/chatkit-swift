import XCTest
@testable import PusherChatkit

class ServiceVersionTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCorrectValueForVersion7() {
        XCTAssertEqual(ServiceVersion.version7.rawValue, "v7")
    }
    
}
