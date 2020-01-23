import XCTest
@testable import PusherChatkit


class ConcreteSubscriptionResponderTests: XCTestCase {
    
    func test_stuff() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(action_expectedCallCount: 1)
        let dummySubscription = DummySubscription()
        
        let dependencies = DependenciesDoubles(
            store: stubStore
        )
        
        let sut = ConcreteSubscriptionResponder(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let jsonData = """
        {
            "data": {
                "current_user": {
                    "id": "viv",
                    "name": "Vivan",
                    "created_at": "0001-01-01T00:00:00Z",
                    "updated_at": "4001-01-01T00:00:00Z"
                },
                "rooms": [],
                "read_states": [],
                "memberships": [],
            },
            "event_name": "initial_state",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        sut.subscription(dummySubscription, didReceiveEventWithJsonData: jsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedAction = Action.subscriptionEvent(
            Wire.Event.EventType.initialState(
                event: Wire.Event.InitialState(currentUser: Wire.User(identifier: "viv",
                                                                      name: "Vivan",
                                                                      avatarURL: nil,
                                                                      customData: nil,
                                                                      createdAt: Date.distantPast,
                                                                      updatedAt: Date.distantFuture,
                                                                      deletedAt: nil),
                                               rooms: [],
                                               readStates: [],
                                               memberships: [])
            )
        )
        
        XCTAssertEqual(stubStore.action_lastReceived, expectedAction)
    }
    
}
