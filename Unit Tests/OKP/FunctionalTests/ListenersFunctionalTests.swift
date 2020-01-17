import XCTest
@testable import PusherChatkit




class ListenersFunctionalTests: XCTestCase {
    
    func test_stuff() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubNetworking = StubNetworking()
        let dependencies = ConcreteDependencies(instanceFactory: stubNetworking)
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        dependencies.storeBroadcaster.register(stubStoreListener)
        
        stubNetworking.stubSubscribe(.session, .success)
        
        let expectation = self.expectation(description: "session subscription successfully connected")
        dependencies.subscriptionManager.subscribe(.session) { result in
            if case .success = result {} else {
                XCTFail("Unexpected session subscription connection failure")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let jsonData = """
        {
            "data": {
                "current_user": {
                    "id": "viv",
                    "name": "Vivan",
                    "created_at": "2017-04-13T14:10:04Z",
                    "updated_at": "2017-04-13T14:10:04Z"
                },
                "rooms": [],
                "read_states": [],
                "memberships": [],
            },
            "event_name": "initial_state",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
//        let jsonData = JsonString.initialStateSubscriptionEvent(type: .withCurrentUserOnly).toJsonData()
        
        stubNetworking.fireSubscriptionEvent(.session, jsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = State(
            currentUser: Internal.User(
                identifier: "viv",
                name: "Vivan"
            ),
            joinedRooms: []
        )
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, expectedState)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)
    }
}
