import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteSubscriptionManagerTests: XCTestCase {
    
    func test_subscribe_subscriptionRegistrationSucceeds_success() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubSubscriptionDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        let stubSubscription = StubSubscription(subscribe_completionResult: .success, delegate: stubSubscriptionDelegate)
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_subscriptionToReturn: stubSubscription)
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = self.expectation(description: "User subscription successfully connected")
        var actualResult: VoidResult?
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(.user) { result in
            actualResult = result
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
        
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

        XCTAssertEqual(actualResult, .success)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_jsonDataLastReceived, jsonData)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_callCount, 1)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveError_callCount, 0)
    }
    
    func test_subscribe_subscriptionRegistrationErrors_failure() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let error = "some error"
        let subscribeResult = VoidResult.failure(error)
        let stubSubscriptionDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 0)
        let stubSubscription = StubSubscription(subscribe_completionResult: subscribeResult, delegate: stubSubscriptionDelegate)
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_subscriptionToReturn: stubSubscription)
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = self.expectation(description: "User subscription successfully connected")
        var actualResult: VoidResult?
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(.user) { result in
            actualResult = result
            expectation.fulfill()
        }
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        waitForExpectations(timeout: 1)

        XCTAssertEqual(actualResult, .failure(error))
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_callCount, 0)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveError_callCount, 0)
    }
    
}
