import XCTest
import TestUtilities
@testable import PusherChatkit

class AuxiliaryStateTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_isComplete_alwaysReturnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = AuxiliaryState(
            subscriptions: [
                .user : .connected
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
        
        let state = AuxiliaryState(
            subscriptions: [
                .user : .initializing(error: nil),
                .room(roomIdentifier: "room-identifier") : .connected
            ]
        )
        
        let supplementalState = AuxiliaryState(
            subscriptions: [
                .user : .initializing(error: FakeError.firstError)
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
    
    func test_hashValue_withEqualSubscriptions_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = AuxiliaryState(
            subscriptions: [
                .user : .connected
            ]
        )
        
        let secondState = AuxiliaryState(
            subscriptions: [
                .user : .connected
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
    
    func test_hashValue_withDifferentSubscriptions_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstState = AuxiliaryState(
            subscriptions: [
                .user : .connected
            ]
        )
        
        let secondState = AuxiliaryState(
            subscriptions: [
                .room(roomIdentifier: "room-identifier") : .connected
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
