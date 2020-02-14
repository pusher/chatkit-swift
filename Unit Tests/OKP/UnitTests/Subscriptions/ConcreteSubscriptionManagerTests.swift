import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteSubscriptionManagerTests: XCTestCase {
    
    func test_subscribe_toUserWhenNoExistingSubscriptions_makesSubscirptionAndSubscribesAndReturnsSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let subscriptionResult: VoidResult = .success
        
        let dummySubscriptionDelegate = DummySubscriptionDelegate()
        
        let stubSubscription = StubSubscription(subscribe_completionResults: [subscriptionResult],
                                                delegate: dummySubscriptionDelegate)
        
        let subscriptionTypeAndSubscriptionToReturn = (subscriptionType: subscriptionType, subscription: stubSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn: [subscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = XCTestExpectation.SubscriptionManager.subscribe
        
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 0)
        XCTAssertEqual(stubSubscription.subscribe_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(subscriptionType, completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(expectation, .success)        
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1) // <-- has increased by one
        XCTAssertEqual(stubSubscription.subscribe_actualCallCount, 1) // <-- has increased by one
    }
    
    func test_subscribe_toRoom1234WhenNoExistingSubscriptions_makesSubscirptionAndSubscribesAndReturnsSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .room(roomIdentifier: "1234")
        let subscriptionResult: VoidResult = .success
        
        let dummySubscriptionDelegate = DummySubscriptionDelegate()
        
        let stubSubscription = StubSubscription(subscribe_completionResults: [subscriptionResult],
                                                delegate: dummySubscriptionDelegate)
        
        let subscriptionTypeAndSubscriptionToReturn = (subscriptionType: subscriptionType, subscription: stubSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn: [subscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = XCTestExpectation.SubscriptionManager.subscribe
        
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 0)
        XCTAssertEqual(stubSubscription.subscribe_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(subscriptionType, completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1) // <-- has increased by one
        XCTAssertEqual(stubSubscription.subscribe_actualCallCount, 1) // <-- has increased by one
    }
    
    func test_subscribe_toUserWhenUserSubscriptionAlreadyActive_doesNothingAndReturnsSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstSubscriptionType: SubscriptionType = .user
        let firstSubscriptionResult: VoidResult = .success
        
        let secondSubscriptionType: SubscriptionType = .user
        let secondSubscriptionResult: VoidResult = .success
        
        let dummySubscriptionDelegate = DummySubscriptionDelegate()
        
        let stubUserSubscription = StubSubscription(subscribe_completionResults: [firstSubscriptionResult, secondSubscriptionResult],
                                                    delegate: dummySubscriptionDelegate)
        
        let firstSubscriptionTypeAndSubscriptionToReturn = (subscriptionType: firstSubscriptionType, subscription: stubUserSubscription)
        let secondSubscriptionTypeAndSubscriptionToReturn = (subscriptionType: secondSubscriptionType, subscription: stubUserSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn:
            [firstSubscriptionTypeAndSubscriptionToReturn, secondSubscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        // Call `subscribe` ** with `.user` ** which should create and hold onto a User Subscription
        let firstExpectation = XCTestExpectation.SubscriptionManager.subscribe
        sut.subscribe(firstSubscriptionType, completion: firstExpectation.handler)
        wait(for: [firstExpectation], timeout: firstExpectation.timeout)
        
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1)
        XCTAssertEqual(stubUserSubscription.subscribe_actualCallCount, 1)
        
        let secondExpectation = XCTestExpectation.SubscriptionManager.subscribe
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(secondSubscriptionType, completion: secondExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [secondExpectation], timeout: secondExpectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .success)
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1) // <-- unchanged (the subscription already existed)
        XCTAssertEqual(stubUserSubscription.subscribe_actualCallCount, 2) // <-- has increased by one
    }
    
    func test_subscribe_toUserWhenRoom1234SubscriptionAlreadyActive_makesSubscirptionAndSubscribesAndReturnsSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstSubscriptionType: SubscriptionType = .room(roomIdentifier: "1234")
        let firstSubscriptionResult: VoidResult = .success
        
        let secondSubscriptionType: SubscriptionType = .user
        let secondSubscriptionResult: VoidResult = .success
        
        let dummySubscriptionDelegate = DummySubscriptionDelegate()
        
        let firstStubSubscription = StubSubscription(subscribe_completionResults: [firstSubscriptionResult],
                                                     delegate: dummySubscriptionDelegate)
        let secondStubSubscription = StubSubscription(subscribe_completionResults: [secondSubscriptionResult],
                                                      delegate: dummySubscriptionDelegate)
        
        let firstSubscriptionTypeAndSubscriptionToReturn = (subscriptionType: firstSubscriptionType, subscription: firstStubSubscription)
        let secondSubscriptionTypeAndSubscriptionToReturn = (subscriptionType: secondSubscriptionType, subscription: secondStubSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn:
            [firstSubscriptionTypeAndSubscriptionToReturn, secondSubscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        // Call `subscribe` ** with `.room(roomIdentifier: "1234")` ** which should create and hold onto a Room Subscription
        let firstExpectation = XCTestExpectation.SubscriptionManager.subscribe
        sut.subscribe(firstSubscriptionType, completion: firstExpectation.handler)
        wait(for: [firstExpectation], timeout: firstExpectation.timeout)
        
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1)
        XCTAssertEqual(firstStubSubscription.subscribe_actualCallCount, 1)
        XCTAssertEqual(secondStubSubscription.subscribe_actualCallCount, 0)
        
        let secondExpectation = XCTestExpectation.SubscriptionManager.subscribe
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(secondSubscriptionType, completion: secondExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [secondExpectation], timeout: secondExpectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .success)
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 2) // <-- has increased by one
        XCTAssertEqual(firstStubSubscription.subscribe_actualCallCount, 1) // <-- unchanged
        XCTAssertEqual(secondStubSubscription.subscribe_actualCallCount, 1) // <-- has increased by one
    }
    
    func test_subscribe_toRoom1234WhenRoom1234SubscriptionAlreadyActive_doesNothingAndReturnsSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstSubscriptionType: SubscriptionType = .room(roomIdentifier: "1234")
        let firstSubscriptionResult: VoidResult = .success
        
        let secondSubscriptionType: SubscriptionType = .room(roomIdentifier: "1234")
        let secondSubscriptionResult: VoidResult = .success
        
        let dummySubscriptionDelegate = DummySubscriptionDelegate()
        
        let roomStubSubscription = StubSubscription(subscribe_completionResults: [firstSubscriptionResult, secondSubscriptionResult],
                                                    delegate: dummySubscriptionDelegate)
        
        let firstSubscriptionTypeAndSubscriptionToReturn = (subscriptionType: firstSubscriptionType, subscription: roomStubSubscription)
        let secondSubscriptionTypeAndSubscriptionToReturn = (subscriptionType: secondSubscriptionType, subscription: roomStubSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn:
            [firstSubscriptionTypeAndSubscriptionToReturn, secondSubscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        // Call `subscribe` ** with `.room(roomIdentifier: "1234")` ** which should create and hold onto a Room Subscription
        let firstExpectation = XCTestExpectation.SubscriptionManager.subscribe
        sut.subscribe(firstSubscriptionType, completion: firstExpectation.handler)
        wait(for: [firstExpectation], timeout: firstExpectation.timeout)
        
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1)
        XCTAssertEqual(roomStubSubscription.subscribe_actualCallCount, 1)
        
        let secondExpectation = XCTestExpectation.SubscriptionManager.subscribe
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(secondSubscriptionType, completion: secondExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [secondExpectation], timeout: secondExpectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .success)
        XCTAssertEqual(stubSubscriptionFactory.makeSubscription_actualCallCount, 1) // <-- unchanged (the subscription already existed)
        XCTAssertEqual(roomStubSubscription.subscribe_actualCallCount, 2) // <-- has increased by one
    }
    
    func test_subscribe_subscriptionRegistrationSucceeds_success() {

        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let subscriptionResult: VoidResult = .success
        
        let stubSubscriptionDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        
        let stubSubscription = StubSubscription(subscribe_completionResults: [subscriptionResult],
                                                delegate: stubSubscriptionDelegate)
        
        let subscriptionTypeAndSubscriptionToReturn = (subscriptionType: subscriptionType, subscription: stubSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn: [subscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = XCTestExpectation.SubscriptionManager.subscribe
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(subscriptionType, completion: expectation.handler)
        
        wait(for: [expectation], timeout: expectation.timeout)
        
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

        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_jsonDataLastReceived, jsonData)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveError_actualCallCount, 0)
    }
    
    func test_subscribe_subscriptionRegistrationErrors_failure() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let error = "some error"
        let subscriptionType: SubscriptionType = .user
        let subscriptionResult: VoidResult = .failure(error)
        
        let stubSubscriptionDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        
        let stubSubscription = StubSubscription(subscribe_completionResults: [subscriptionResult],
                                                delegate: stubSubscriptionDelegate)
        
        let subscriptionTypeAndSubscriptionToReturn = (subscriptionType: subscriptionType, subscription: stubSubscription)
        
        let stubSubscriptionFactory = StubSubscriptionFactory(makeSubscription_expectedTypesAndSubscriptionsToReturn: [subscriptionTypeAndSubscriptionToReturn])
        
        let dependencies = DependenciesDoubles(
            subscriptionFactory: stubSubscriptionFactory
        )
        
        let sut = ConcreteSubscriptionManager(dependencies: dependencies)
        
        let expectation = XCTestExpectation.SubscriptionManager.subscribe
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.subscribe(subscriptionType, completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertExpectationFulfilledWithResult(expectation, .failure(error))
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubSubscriptionDelegate.didReceiveError_actualCallCount, 0)
    }
    
}
