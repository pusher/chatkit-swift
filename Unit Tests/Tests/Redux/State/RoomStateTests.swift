import XCTest
@testable import PusherChatkit

class RoomStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_alwaysReturnsTrue() {
        
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
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_supplement_alwaysReturnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = RoomState(
            identifier: "test-identifier",
            name: "test-name-1",
            isPrivate: true,
            pushNotificationTitle: "test-push-notification-title",
            customData: [
                "test-key-1" : "test-value-1"
            ],
            lastMessageAt: .distantPast,
            readSummary: ReadSummaryState(
                unreadCount: 10
            ),
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let supplementalState = RoomState(
            identifier: "test-identifier",
            name: "test-name-2",
            isPrivate: false,
            pushNotificationTitle: "test-push-notification-title-2",
            customData: [
                "test-key-2" : "test-value-2"
            ],
            lastMessageAt: .distantFuture,
            readSummary: ReadSummaryState(
                unreadCount: 20
            ),
            createdAt: .distantPast,
            updatedAt: .distantFuture
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.supplement(withState: supplementalState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, state)
    }
    
}
