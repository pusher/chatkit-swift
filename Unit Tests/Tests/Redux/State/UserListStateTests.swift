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
            users: [
                "test-identifier-1" : .populated(
                    identifier: "test-identifier-1",
                    name: "test-name-1"
                ),
                "test-identifier-2" : .populated(
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
            users: [
                "test-identifier-1" : .populated(
                    identifier: "test-identifier-1",
                    name: "test-name-1"
                ),
                "test-identifier-2" : .partial(
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
            users: [
                "test-identifier-1" : .populated(
                    identifier: "test-identifier-1",
                    name: "test-name-1"
                ),
                "test-identifier-2" : .partial(
                    identifier: "test-identifier-2"
                ),
                "test-identifier-3" : .partial(
                    identifier: "test-identifier-3"
                )
            ]
        )
        
        let supplementalState = UserListState(
            users: [
                "test-identifier-2" : .populated(
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
            users: [
                "test-identifier-1" : .populated(
                    identifier: "test-identifier-1",
                    name: "test-name-1"
                ),
                "test-identifier-2" : .populated(
                    identifier: "test-identifier-2",
                    name: "test-name-2"
                ),
                "test-identifier-3" : .partial(
                    identifier: "test-identifier-3"
                )
            ]
        )
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
}
