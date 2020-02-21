import XCTest
@testable import PusherChatkit

class RoomTransformerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_transform_mapsStateToPublicModel() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = RoomState(
            identifier: "test-identifier",
            name: "test-name",
            isPrivate: true,
            pushNotificationTitle: "test-push-notification-title",
            customData: [
                "test-key" : "test-value"
            ],
            lastMessageAt: .distantPast,
            readSummary: ReadSummaryState(
                unreadCount: 10
            ),
            createdAt: .distantPast,
            updatedAt: .distantFuture
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let room = RoomTransformer.transform(state: state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(room.identifier, "test-identifier")
        XCTAssertEqual(room.name, "test-name")
        XCTAssertEqual(room.identifier, "test-identifier")
        XCTAssertTrue(room.isPrivate)
        XCTAssertEqual(room.unreadCount, 10)
        XCTAssertEqual(room.lastMessageAt, .distantPast)
        XCTAssertEqual(room.customData?.count, 1)
        XCTAssertEqual(room.customData?["test-key"] as? String, "test-value")
        XCTAssertEqual(room.createdAt, .distantPast)
        XCTAssertEqual(room.updatedAt, .distantFuture)
    }
    
}
