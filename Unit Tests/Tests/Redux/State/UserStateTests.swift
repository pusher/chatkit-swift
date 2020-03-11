import XCTest
@testable import PusherChatkit

class UserStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_identifier_returnsIdentifierForPartialUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .partial(
            identifier: "test-identifier"
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.identifier
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, "test-identifier")
    }
    
    func test_identifier_returnsIdentifierForPopulatedUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .populated(
            identifier: "test-identifier",
            name: "test-name"
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.identifier
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, "test-identifier")
    }
    
    func test_identifier_returnsNilForEmptyUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .empty
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.identifier
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_isComplete_returnsTrueForPopulatedUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .populated(
            identifier: "test-identifier",
            name: "test-name"
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
    
    func test_isComplete_returnsTrueForEmptyUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .empty
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = state.isComplete
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_isComplete_returnsFalseForPartialUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .partial(
            identifier: "test-identifier"
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
    
    func test_supplement_shouldNotSupplementEmptyUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .empty
        
        let supplementalState: UserState = .populated(
            identifier: "test-identifier",
            name: "test-name"
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
    
    func test_supplement_shouldNotSupplementPartialUserWithDifferentIdentifier() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .partial(
            identifier: "test-identifier-1"
        )
        
        let supplementalState: UserState = .populated(
            identifier: "test-identifier-2",
            name: "test-name"
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
    
    func test_supplement_shouldSupplementPartialUserWithEqualIdentifier() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .partial(
            identifier: "test-identifier"
        )
        
        let supplementalState: UserState = .populated(
            identifier: "test-identifier",
            name: "test-name"
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
    
    func test_supplement_shouldNotSupplementPopulatedUser() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state: UserState = .populated(
            identifier: "test-identifier",
            name: "test-name-1"
        )
        
        let supplementalState: UserState = .populated(
            identifier: "test-identifier",
            name: "test-name-2"
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
