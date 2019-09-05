import XCTest
@testable import PusherChatkit

class ServiceNameTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCorrectValueForChatServiceName() {
        XCTAssertEqual(ServiceName.chat.rawValue, "chatkit")
    }
    
    func testShouldHaveCorrectValueForCursorsServiceName() {
        XCTAssertEqual(ServiceName.cursors.rawValue, "chatkit_cursors")
    }
    
    func testShouldHaveCorrectValueForPresenceServiceName() {
        XCTAssertEqual(ServiceName.presence.rawValue, "chatkit_presence")
    }
    
    func testShouldHaveCorrectValueForPushNotificationServiceName() {
        XCTAssertEqual(ServiceName.pushNotification.rawValue, "chatkit_beams_token_provider")
    }
    
}
