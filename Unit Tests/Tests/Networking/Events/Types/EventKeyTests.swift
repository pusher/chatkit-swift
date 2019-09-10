import XCTest
@testable import PusherChatkit

class EventKeyTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldHaveCorrectValueForCreatedAtEventKey() {
        XCTAssertEqual(Event.Key.createdAt, "created_at")
    }
    
    func testShouldHaveCorrectValueForCustomDataKey() {
        XCTAssertEqual(Event.Key.customData, "custom_data")
    }
    
    func testShouldHaveCorrectValueForDataEventKey() {
        XCTAssertEqual(Event.Key.data, "data")
    }
    
    func testShouldHaveCorrectValueForDeletedAtEventKey() {
        XCTAssertEqual(Event.Key.deletedAt, "deleted_at")
    }
    
    func testShouldHaveCorrectValueForEventNameEventKey() {
        XCTAssertEqual(Event.Key.eventName, "event_name")
    }
    
    func testShouldHaveCorrectValueForIdentifierEventKey() {
        XCTAssertEqual(Event.Key.identifier, "id")
    }
    
    func testShouldHaveCorrectValueForNameEventKey() {
        XCTAssertEqual(Event.Key.name, "name")
    }
    
    func testShouldHaveCorrectValueForPrivateEventKey() {
        XCTAssertEqual(Event.Key.private, "private")
    }
    
    func testShouldHaveCorrectValueForRoomsEventKey() {
        XCTAssertEqual(Event.Key.rooms, "rooms")
    }
    
    func testShouldHaveCorrectValueForUnreadCountEventKey() {
        XCTAssertEqual(Event.Key.unreadCount, "unread_count")
    }
    
    func testShouldHaveCorrectValueForUpdatedAtEventKey() {
        XCTAssertEqual(Event.Key.updatedAt, "updated_at")
    }
    
}
