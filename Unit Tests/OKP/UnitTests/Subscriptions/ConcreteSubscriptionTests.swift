import TestUtilities
import XCTest
@testable import PusherChatkit


extension XCTestCase {
    
    func setUp_notSubscribed(file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate) {
            
            let subscriptionType: SubscriptionType = .user
            let instanceType: InstanceType = .subscription(subscriptionType)
            let result: VoidResult = .success
            
            let stubInstance = StubInstance(subscribe_completionResult: result)
            
            let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
                [(instanceType: instanceType, instance: stubInstance)])
            let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory)
            
            let stubDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
            
            let sut = ConcreteSubscription(subscriptionType: subscriptionType,
                                           dependencies: dependencies,
                                           delegate: stubDelegate)
            
            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 0)
            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 0)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
            
            // Current state:
            // `ConcreteSubscription.state` is `.notSubscribed`
            
            return (sut, stubInstance, stubInstanceFactory, stubDelegate)
    }
    
    func setUp_subscribingStageTwo(file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate, XCTestExpectation.Expectation<VoidResult>) {
            
            let (sut, stubInstance, stubInstanceFactory, stubDelegate) = setUp_notSubscribed()
            
            let expectation = XCTestExpectation.Subscription.subscribe
            
            sut.subscribe(completion: expectation.handler)
            
            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
            
            // Current state
            // `ConcreteSubscription.state` is `.subscribingStageTwo`
            // `completion` handler has NOT been invoked
            
            return (sut, stubInstance, stubInstanceFactory, stubDelegate, expectation)
    }
    
    func setUp_subscribed(file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate) {
            
            let (sut, stubInstance, stubInstanceFactory, stubDelegate, expectation) = setUp_subscribingStageTwo()
            
            let jsonData = "{}".toJsonData()
            stubInstance.fireSubscriptionEvent(jsonData: jsonData)
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            XCTAssertExpectationFulfilled(expectation) { result in
                XCTAssertEqual(result, .success)
            }
            
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
            
            // Current state
            // `ConcreteSubscription.state` is `.subscribed`
            // `completion` handler HAS been invoked
            
            return (sut, stubInstance, stubInstanceFactory, stubDelegate)
    }
}



class ConcreteSubscriptionTests: XCTestCase {
    
    func test_subscribe_whenNotSubscribedAndEventSubsequentlyFires_completionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let instanceType: InstanceType = .subscription(subscriptionType)
        let result: VoidResult = .success
        
//        let stubInstance = StubInstance(subscribe_completionResult: result)
//
//        let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
//            [(instanceType: instanceType, instance: stubInstance)])
//        let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory)
//
//        let stubDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
//
//        let sut = ConcreteSubscription(subscriptionType: subscriptionType,
//                                       dependencies: dependencies,
//                                       delegate: stubDelegate)
//
//
//        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 0)
//        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 0)
//        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        
        // `ConcreteSubscription.state` is currently `.notSubscribed`
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate) = setUp_notSubscribed()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let expectation = XCTestExpectation.Subscription.subscribe
        
        // Call `subscribe` to progress `ConcreteSubscription.state` from `.notSubscribed` -> `.subscribingStageTwo`
        sut.subscribe(completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Fire a subscription event to progress `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        // `completion` should now be invoked with `.success`
        let jsonData = "{}".toJsonData()
        stubInstance.fireSubscriptionEvent(jsonData: jsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilled(expectation) { result in
            XCTAssertEqual(result, .success)
        }
        
        // Delegate should have been informed of the event that fired
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_subscribe_whenSubscribingStageTwoAndEventSubsequentlyFires_completionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let instanceType: InstanceType = .subscription(subscriptionType)
        let result: VoidResult = .success
        
        //        let stubInstance = StubInstance(subscribe_completionResult: result)
        //
        //        let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
        //            [(instanceType: instanceType, instance: stubInstance)])
        //        let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory)
        //
        //        let stubDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        //
        //        let sut = ConcreteSubscription(subscriptionType: subscriptionType,
        //                                       dependencies: dependencies,
        //                                       delegate: stubDelegate)
        //
        //        let firstExpectation = XCTestExpectation.Subscription.subscribe
        //
        //        sut.subscribe(completion: firstExpectation.handler)
        //
        //        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        //        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        //        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        //
        //        // `ConcreteSubscription.state` is currently `.subscribingStageTwo`
        //        // And the first `completion` handler has not yet been invoked
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation)
            = setUp_subscribingStageTwo()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let secondExpectation = XCTestExpectation.Subscription.subscribe
        
        sut.subscribe(completion: secondExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Neither expecation should become fulfilled until a subscription event is fired
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        // This should NOT factory a new `Instance` nor call `subscribeToResume` on the existing `Instance` either
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Fire a subscription event to progress `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        // BOTH `completion` handlers should now be invoked with `.success`
        let jsonData = "{}".toJsonData()
        stubInstance.fireSubscriptionEvent(jsonData: jsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        // Both expectations shoudld have been fulfilled with `.success`
        XCTAssertExpectationFulfilled(firstExpectation) { result in
            XCTAssertEqual(result, .success)
        }
        XCTAssertExpectationFulfilled(secondExpectation) { result in
            XCTAssertEqual(result, .success)
        }
        
        // Delegate should have been informed of the event that fired
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        
        // No further calls should have been made to factory a new `Instance` nor `subscribeToResume`
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_subscribe_whenSubscribedAndEventSubsequentlyFires_completionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let instanceType: InstanceType = .subscription(subscriptionType)
        let result: VoidResult = .success
        
        //        let stubInstance = StubInstance(subscribe_completionResult: result)
        //
        //        let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
        //            [(instanceType: instanceType, instance: stubInstance)])
        //        let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory)
        //
        //        let stubDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        //
        //        let sut = ConcreteSubscription(subscriptionType: subscriptionType,
        //                                       dependencies: dependencies,
        //                                       delegate: stubDelegate)
        //
        //        let firstExpectation = XCTestExpectation.Subscription.subscribe
        //
        //        sut.subscribe(completion: firstExpectation.handler)
        //
        //        let jsonData = "{}".toJsonData()
        //        stubInstance.fireSubscriptionEvent(jsonData: jsonData)
        //
        //        wait(for: [firstExpectation], timeout: firstExpectation.timeout)
        //
        //        XCTAssertExpectationFulfilled(firstExpectation) { result in
        //            XCTAssertEqual(result, .success)
        //        }
        //
        //        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        //        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        //        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        //
        //        // The first `completion` handler has already been invoked
        //        // `ConcreteSubscription.state` is currently `.subscribed`
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate) = setUp_subscribed()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let secondExpectation = XCTestExpectation.Subscription.subscribe
        
        sut.subscribe(completion: secondExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [secondExpectation], timeout: secondExpectation.timeout)
        
        XCTAssertExpectationFulfilled(secondExpectation) { result in
            XCTAssertEqual(result, .success)
        }
        
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
    }
}
