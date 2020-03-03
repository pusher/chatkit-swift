import XCTest
@testable import PusherChatkit

class ChatStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_shouldReturnTrueForEmptyState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: ChatState = .empty
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_isComplete_shouldReturnTrueWhenAllUsersAreComplete() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = ChatState(
            currentUser: .populated(
                identifier: "test-identifier-1",
                name: "test-name-1"
            ),
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .populated(
                        identifier: "test-identifier-1",
                        name: "test-name-1"
                    ),
                    .populated(
                        identifier: "test-identifier-2",
                        name: "test-name-2"
                    )
                ]
            )
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
    
    func test_isComplete_shouldReturnFalseWhenAtLeastOneUserIsIncomplete() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = ChatState(
            currentUser: .populated(
                identifier: "test-identifier-1",
                name: "test-name-1"
            ),
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .populated(
                        identifier: "test-identifier-1",
                        name: "test-name-1"
                    ),
                    .partial(
                        identifier: "test-identifier-2"
                    )
                ]
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_isComplete_shouldReturnFalseWhenCurrentUserIsIncomplete() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = ChatState(
            currentUser: .partial(
                identifier: "test-identifier-3"
            ),
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .populated(
                        identifier: "test-identifier-1",
                        name: "test-name-1"
                    ),
                    .populated(
                        identifier: "test-identifier-2",
                        name: "test-name-1"
                    )
                ]
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_supplement_shouldSupplementIncompleteUsers() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = ChatState(
            currentUser: .empty,
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .populated(
                        identifier: "test-identifier-1",
                        name: "test-name-1"
                    ),
                    .partial(
                        identifier: "test-identifier-2"
                    )
                ]
            )
        )
        
        let supplementalState = ChatState(
            currentUser: .empty,
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .populated(
                        identifier: "test-identifier-1",
                        name: "test-name-1"
                    ),
                    .populated(
                        identifier: "test-identifier-2",
                        name: "test-name-2"
                    )
                ]
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.supplement(withState: supplementalState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, supplementalState)
    }
    
    func test_supplement_shouldSupplementIncompleteCurrentUsers() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = ChatState(
            currentUser: .partial(
                identifier: "test-identifier-3"
            ),
            joinedRooms: .empty,
            users: .empty
        )
        
        let supplementalState = ChatState(
            currentUser: .populated(
                identifier: "test-identifier-3",
                name: "test-name-3"
            ),
            joinedRooms: .empty,
            users: .empty
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.supplement(withState: supplementalState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, supplementalState)
    }
    
    func test_hashValue_withEqualProperties_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: ChatState = .empty
        
        let secondState: ChatState = .empty
        
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
    
    func test_hashValue_withDifferentCurrentUser_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = ChatState(
            currentUser: .partial(identifier: "user-identifier"),
            joinedRooms: .empty,
            users: .empty
        )
        
        let secondState: ChatState = .empty
        
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
    
    func test_hashValue_withDifferentJoinedRooms_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                elements: [
                    RoomState(
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
                ]
            ),
            users: .empty
        )
        
        let secondState: ChatState = .empty
        
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
    
    func test_hashValue_withDifferentUsers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = ChatState(
            currentUser: .empty,
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .partial(identifier: "user-identifier")
                ]
            )
        )
        
        let secondState: ChatState = .empty
        
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
