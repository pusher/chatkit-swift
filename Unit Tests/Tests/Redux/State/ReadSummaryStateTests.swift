import XCTest
@testable import PusherChatkit

class ReadSummaryStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_alwaysReturnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = ReadSummaryState(
            unreadCount: 10
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
        
        let state = ReadSummaryState(
            unreadCount: 10
        )
        
        let supplementalState = ReadSummaryState(
            unreadCount: 20
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
    
    func test_hashValue_withEqualUnreadCounts_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = ReadSummaryState(
            unreadCount: 10
        )
        
        let secondState = ReadSummaryState(
            unreadCount: 10
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
    
    func test_hashValue_withDifferentUnreadCounts_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = ReadSummaryState(
            unreadCount: 10
        )
        
        let secondState = ReadSummaryState(
            unreadCount: 20
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
