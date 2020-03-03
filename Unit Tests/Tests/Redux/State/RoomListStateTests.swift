import XCTest
@testable import PusherChatkit

class RoomListStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_alwaysReturnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = RoomListState(
            elements: [
                RoomState(
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
            ]
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
        
        let state = RoomListState(
            elements: [
                RoomState(
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
                ),
                RoomState(
                    identifier: "test-identifier-2",
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
            ]
        )
        
        let supplementalState = RoomListState(
            elements: [
                RoomState(
                    identifier: "test-identifier",
                    name: "test-name-3",
                    isPrivate: false,
                    pushNotificationTitle: "test-push-notification-title-3",
                    customData: [
                        "test-key-3" : "test-value-3"
                    ],
                    lastMessageAt: .distantFuture,
                    readSummary: ReadSummaryState(
                        unreadCount: 20
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantFuture
                ),
                RoomState(
                    identifier: "test-identifier-4",
                    name: "test-name-4",
                    isPrivate: false,
                    pushNotificationTitle: "test-push-notification-title-4",
                    customData: [
                        "test-key-4" : "test-value-4"
                    ],
                    lastMessageAt: .distantFuture,
                    readSummary: ReadSummaryState(
                        unreadCount: 20
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantFuture
                )
            ]
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
        
        let roomState = RoomState(
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
        
        let firstState = RoomListState(
            elements: [
                "room-identifier" : roomState
            ]
        )
        
        let secondState = RoomListState(
            elements: [
                "room-identifier" : roomState
            ]
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
    
    func test_hashValue_withDifferentElements_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomState = RoomState(
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
        
        let firstState = RoomListState(
            elements: [
                "different-room-identifier" : roomState
            ]
        )
        
        let secondState = RoomListState(
            elements: [
                "room-identifier" : roomState
            ]
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
