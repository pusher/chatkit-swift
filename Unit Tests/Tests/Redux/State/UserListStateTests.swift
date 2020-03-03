import XCTest
@testable import PusherChatkit

class UserListStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_shouldReturnTrueForEmptyState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserListState = .empty
        
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
        
        let state = UserListState(
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
        
        let state = UserListState(
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
        
        let state = UserListState(
            elements: [
                .populated(
                    identifier: "test-identifier-1",
                    name: "test-name-1"
                ),
                .partial(
                    identifier: "test-identifier-2"
                ),
                .partial(
                    identifier: "test-identifier-3"
                )
            ]
        )
        
        let supplementalState = UserListState(
            elements: [
                .populated(
                    identifier: "test-identifier-2",
                    name: "test-name-2"
                )
            ]
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.supplement(withState: supplementalState)
        
        let expectedState = UserListState(
            elements: [
                .populated(
                    identifier: "test-identifier-1",
                    name: "test-name-1"
                ),
                .populated(
                    identifier: "test-identifier-2",
                    name: "test-name-2"
                ),
                .partial(
                    identifier: "test-identifier-3"
                )
            ]
        )
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_hashValue_withEqualElements_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let userState: UserState = .partial(identifier: "user-identifier")
        
        let firstState = UserListState(
            elements: [
                "user-identifier" : userState
            ]
        )
        
        let secondState = UserListState(
            elements: [
                "user-identifier" : userState
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
        
        let userState: UserState = .partial(identifier: "user-identifier")
        
        let firstState = UserListState(
            elements: [
                "different-user-identifier" : userState
            ]
        )
        
        let secondState = UserListState(
            elements: [
                "user-identifier" : userState
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
