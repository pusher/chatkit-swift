import XCTest
@testable import PusherChatkit

class VersionedStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_shouldReturnTrueForInitialState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: VersionedState = .initial
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_isComplete_shouldReturnTrueWhenChatStateIsComplete() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = VersionedState(
            chatState: ChatState(
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
            ),
            version: 1,
            signature: .initialState
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
    
    func test_isComplete_shouldReturnFalseWhenChatStateIsIncomplete() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = VersionedState(
            chatState: ChatState(
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
            ),
            version: 1,
            signature: .initialState
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
    
    func test_supplement_shouldSupplementIncompleteChatState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = VersionedState(
            chatState: ChatState(
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
            ),
            version: 1,
            signature: .initialState
        )
        
        let supplementalState = VersionedState(
            chatState: ChatState(
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
                        ),
                        .populated(
                            identifier: "test-identifier-3",
                            name: "test-name-3"
                        )
                    ]
                )
            ),
            version: 2,
            signature: .addedToRoom
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.supplement(withState: supplementalState)
        
        let expectedState = VersionedState(
            chatState: ChatState(
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
            ),
            version: 1,
            signature: .initialState
        )
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
}
