import XCTest
@testable import PusherChatkit

class ServiceVersionTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCorrectValueForVersion1() {
        XCTAssertEqual(ServiceVersion.version1.rawValue, "v1")
    }
    
    func testShouldHaveCorrectValueForVersion2() {
        XCTAssertEqual(ServiceVersion.version2.rawValue, "v2")
    }
    
    func testShouldHaveCorrectValueForVersion6() {
        XCTAssertEqual(ServiceVersion.version6.rawValue, "v6")
    }
    
}
