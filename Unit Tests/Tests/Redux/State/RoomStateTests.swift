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
    
    func test_hashValue_withEqualElements_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentIdentifiers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "different-room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentNames_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "different-room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentIsPrivates_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: true,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentPushNotificationTitles_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: "push-notification-title",
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentCustomDatas_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: [
                "custom-data-key" : "custom-data-value"
            ],
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentLastMessageAts_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: .distantPast,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentReadSummaries_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: ReadSummaryState(
                unreadCount: 10
            ),
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentCreatedAts_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantFuture,
            updatedAt: .distantPast
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
    func test_hashValue_withDifferentUpdatedAts_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantPast
        )
        
        let secondState = RoomState(
            identifier: "room-identifier",
            name: "room-name",
            isPrivate: false,
            pushNotificationTitle: nil,
            customData: nil,
            lastMessageAt: nil,
            readSummary: .empty,
            createdAt: .distantPast,
            updatedAt: .distantFuture
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstStateHashValue = firstState.hashValue
        let secondStateHashValue = secondState.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstStateHashValue, secondStateHashValue)
    }
    
}
