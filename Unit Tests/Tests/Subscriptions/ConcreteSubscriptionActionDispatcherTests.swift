import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteSubscriptionActionDispatcherTests: XCTestCase {
    
    func test_didReceiveEvent_withValidJson_notifiesStore() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial, dispatch_expectedCallCount: 1)
        let dummySubscription = DummySubscription()
        
        let dependencies = DependenciesDoubles(
            store: stubStore
        )
        
        let sut = ConcreteSubscriptionActionDispatcher(dependencies: dependencies)
        
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
        
        let expectedAction = InitialStateAction(
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
        
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubStore.dispatch_lastReceived as? InitialStateAction, expectedAction)
    }
    
    func test_didReceiveEvent_withInvalidJson_doesNotNotifyStore() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial, dispatch_expectedCallCount: 0)
        let dummySubscription = DummySubscription()
        
        let dependencies = DependenciesDoubles(
            store: stubStore
        )
        
        let sut = ConcreteSubscriptionActionDispatcher(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let jsonData = """
        {
            "not valid"
        }
        """.toJsonData(validate: false)
        
        sut.subscription(dummySubscription, didReceiveEventWithJsonData: jsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/

        XCTAssertEqual(stubStore.dispatch_actualCallCount, 0)
        XCTAssertNil(stubStore.dispatch_lastReceived)
    }
    
    func test_didReceiveError_regardless_doesNotNotifyStore() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial, dispatch_expectedCallCount: 0)
        let dummySubscription = DummySubscription()
        
        let dependencies = DependenciesDoubles(
            store: stubStore
        )
        
        let sut = ConcreteSubscriptionActionDispatcher(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let error = FakeError.firstError
        
        sut.subscription(dummySubscription, didReceiveError: error)
        
        /******************/
        /*----- THEN -----*/
        /******************/

        XCTAssertEqual(stubStore.dispatch_actualCallCount, 0)
        XCTAssertNil(stubStore.dispatch_lastReceived)
    }
}
