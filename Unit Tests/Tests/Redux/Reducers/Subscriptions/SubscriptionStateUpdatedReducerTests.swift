import XCTest
import TestUtilities
@testable import PusherChatkit

class SubscriptionStateUpdatedReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withNotSubscribedSubscriptionState_setsConnectionStateToClosed() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: AuxiliaryState = .empty
        
        let action = SubscriptionStateUpdatedAction(
            type: .user,
            state: .notSubscribed
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
                .user : .closed(error: nil)
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withSubscribingSubscriptionState_setsConnectionStateToInitializing() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: AuxiliaryState = .empty
        
        let action = SubscriptionStateUpdatedAction(
            type: .user,
            state: .subscribing
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
                .user : .initializing(error: nil)
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withSubscribedSubscriptionState_setsConnectionStateToConnected() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: AuxiliaryState = .empty
        
        let action = SubscriptionStateUpdatedAction(
            type: .user,
            state: .subscribed
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
                .user : .connected
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
