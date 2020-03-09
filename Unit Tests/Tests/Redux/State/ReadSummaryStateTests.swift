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
    
}
