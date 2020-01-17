import XCTest
@testable import PusherChatkit

class ConcreteSubscriptionManagerTests: XCTestCase {
    
    func test_stuff() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubSubscriptionDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        let stubSubscription = StubSubscription(subscribe_completionResult: .success(()), delegate: stubSubscriptionDelegate)
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_subscriptionToReturn: stubSubscription)
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = self.expectation(description: "session subscription successfully connected")
        sut.subscribe(.session) { result in
            if case .success = result {} else {
                XCTFail("Unexpected session subscription connection failure")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let jsonData = """
        {
            "current_user": {
                "id": "viv",
                "name": "Vivan",
                "created_at": "2017-04-13T14:10:04Z",
                "updated_at": "2017-04-13T14:10:04Z"
            },
            "rooms": [],
            "read_states": [],
            "memberships": [],
        }
        """.toJsonData()
        
        stubSubscription.fireSubscriptionEvent(jsonData: jsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_jsonDataLastReceived, jsonData)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_callCount, 1)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveError_callCount, 0)
    }
    
}

