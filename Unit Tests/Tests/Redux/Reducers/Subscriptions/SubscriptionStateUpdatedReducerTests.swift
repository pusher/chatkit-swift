import XCTest
import TestUtilities
@testable import PusherChatkit

class SubscriptionStateUpdatedReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withSubscriptionStateUpdatedAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: AuxiliaryState = .empty
        
        // TODO: We should rewrite this test when SubscriptionType will become available available.
        let action = SubscriptionStateUpdatedAction(
            type: "user",
            state: "connected"
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Subscription.StateUpdated.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = AuxiliaryState(
            subscriptions: [
                "user" : .connected
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
