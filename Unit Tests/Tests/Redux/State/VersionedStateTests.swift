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
            auxiliaryState: .empty,
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
            auxiliaryState: .empty,
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
            auxiliaryState: .empty,
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
            auxiliaryState: .empty,
            version: 2,
            signature: .subscriptionStateUpdated
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
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_hashValue_withEqualProperties_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState: VersionedState = .initial
        
        let secondState: VersionedState = .initial
        
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
    
    func test_hashValue_withDifferentChatStates_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = VersionedState(
            chatState: ChatState(
                currentUser: .partial(identifier: "user-identifier"),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 0,
            signature: .unsigned
        )
        
        let secondState: VersionedState = .initial
        
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
    
    func test_hashValue_withDifferentAuxiliaryStates_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    "user" : .connected
                ]
            ),
            version: 0,
            signature: .unsigned
        )
        
        let secondState: VersionedState = .initial
        
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
    
    func test_hashValue_withDifferentVersions_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .unsigned
        )
        
        let secondState: VersionedState = .initial
        
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
    
    func test_hashValue_withDifferentSignatures_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 0,
            signature: .initialState
        )
        
        let secondState: VersionedState = .initial
        
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
