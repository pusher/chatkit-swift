import TestUtilities
import XCTest
@testable import PusherChatkit


extension XCTestCase {

    fileprivate enum ConcreteSubscriptionAssertableState {
        case notSubscribed
        case subscribingStageOne
        case subscribingStageTwo
        case subscribed
    }
    
    fileprivate func XCTAssertEqualState(_ actualState: ConcreteSubscription.State,
                                         _ expectedAssertableState: ConcreteSubscriptionAssertableState,
                                         file: StaticString = #file, line: UInt = #line) {
        switch actualState {
        case .notSubscribed:
            if case .notSubscribed = expectedAssertableState { return }
        case .subscribingStageOne:
            if case .subscribingStageOne = expectedAssertableState { return }
        case .subscribingStageTwo:
            if case .subscribingStageTwo = expectedAssertableState { return }
        case .subscribed:
            if case .subscribed = expectedAssertableState { return }
        }

        XCTFail("Expected state of `\(expectedAssertableState)` but got `\(actualState) instead", file: file, line: line)
    }

    //    func setUp_notSubscribed(forType subscriptionType: SubscriptionType,
    //                             file: StaticString = #file, line: UInt = #line)
    //        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate) {
    //
    //            let instanceType: InstanceType = .subscription(subscriptionType)
    //
    //            let stubInstance = StubInstance(subscribeWithResume_expectedCallCount: 1, file: file, line: line)
    //
    //            let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
    //                [(instanceType: instanceType, instance: stubInstance)], file: file, line: line)
    //            let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory, file: file, line: line)
    //
    //            let stubDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1, file: file, line: line)
    //
    //            let sut = ConcreteSubscription(subscriptionType: subscriptionType,
    //                                           dependencies: dependencies,
    //                                           delegate: stubDelegate)
    //
    //            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 0, file: file, line: line)
    //            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 0, file: file, line: line)
    //            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0, file: file, line: line)
    //
    //            // Current state:
    //            // `ConcreteSubscription.state` is `.notSubscribed`
    //
    //            return (sut, stubInstance, stubInstanceFactory, stubDelegate)
    //    }
    
    func setUp_subscribingStageTwo(forType subscriptionType: SubscriptionType,
                                   stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
                                   stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
                                   stubResumableSubscription_end_expected: Bool? = nil,
                                   file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate, XCTestExpectation.Expectation<VoidResult>) {
            
            let instanceType: InstanceType = .subscription(subscriptionType)
            
            let stubInstance = StubInstance(
                subscribeWithResume_expectedCallCount: 1,
                resumableSubscription_end_expected: stubResumableSubscription_end_expected ?? false,
                file: file, line: line)
            
            let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
                [(instanceType: instanceType, instance: stubInstance)], file: file, line: line)
            
            let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory, file: file, line: line)
            
            let stubDelegate = StubSubscriptionDelegate(
                didReceiveEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount ?? 1,
                didReceiveError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount ?? 0,
                file: file, line: line)
            
            let sut = ConcreteSubscription(subscriptionType: subscriptionType,
                                           dependencies: dependencies,
                                           delegate: stubDelegate)
            
//            let (sut, stubInstance, stubInstanceFactory, stubDelegate)
//                = setUp_notSubscribed(forType: subscriptionType, file: file, line: line)
            
            let expectation = XCTestExpectation.Subscription.subscribe
            
            XCTAssertEqualState(sut.state, .notSubscribed, file: file, line: line)
            XCTAssertExpectationUnfulfilled(expectation, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 0, file: file, line: line)
            
            sut.subscribe(completion: expectation.handler)
            
            XCTAssertEqualState(sut.state, .subscribingStageTwo, file: file, line: line)
            XCTAssertExpectationUnfulfilled(expectation, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1, file: file, line: line)
            
            // Current state
            // `ConcreteSubscription.state` is `.subscribingStageTwo`
            // `completion` handler has NOT been invoked
            
            return (sut, stubInstance, stubInstanceFactory, stubDelegate, expectation)
    }
    
    func setUp_subscribingStageTwoWithMultipleWaitingCompletions(
        forType subscriptionType: SubscriptionType,
        stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
        stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
        stubResumableSubscription_end_expected: Bool? = nil,
        file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate, XCTestExpectation.Expectation<VoidResult>, XCTestExpectation.Expectation<VoidResult>) {

        let (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation)
            = setUp_subscribingStageTwo(forType: subscriptionType,
                                        stubDelegate_didReceivedEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount,
                                        stubDelegate_didReceivedError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount,
                                        stubResumableSubscription_end_expected: stubResumableSubscription_end_expected,
                                        file: file, line: line)

        let secondExpectation = XCTestExpectation.Subscription.subscribe
            
        sut.subscribe(completion: secondExpectation.handler)
            
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)

        return (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation, secondExpectation)
    }
            
    func setUp_subscribed(forType subscriptionType: SubscriptionType,
                          stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
                          stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
                          stubResumableSubscription_end_expected: Bool? = nil,
                          file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubInstance, StubInstanceFactory, StubSubscriptionDelegate) {
            
            let (sut, stubInstance, stubInstanceFactory, stubDelegate, expectation)
                = setUp_subscribingStageTwo(forType: subscriptionType,
                                            stubDelegate_didReceivedEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount,
                                            stubDelegate_didReceivedError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount,
                                            file: file, line: line)
            
            let jsonData = "{}".toJsonData()
            stubInstance.fireOnEvent(jsonData: jsonData)
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            XCTAssertEqualState(sut.state, .subscribed, file: file, line: line)
            XCTAssertExpectationFulfilledWithResult(expectation, .success, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1, file: file, line: line)
            
            // Current state
            // `ConcreteSubscription.state` is `.subscribed`
            // `completion` handler HAS been invoked
            
            return (sut, stubInstance, stubInstanceFactory, stubDelegate)
    }
}


class ConcreteSubscriptionTests: XCTestCase {
    
    // MARK: subscribe(completion:)
    
    func test_subscribe_whenNotSubscribed_becomesSubscribingStageTwoAndCompletionNotInvoked() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user

        let instanceType: InstanceType = .subscription(subscriptionType)
        
        let stubInstance = StubInstance(subscribeWithResume_expectedCallCount: 1)
        
        let stubInstanceFactory = StubInstanceFactory(makeInstance_expectedTypesAndInstancesToReturn:
            [(instanceType: instanceType, instance: stubInstance)])
        
        let dependencies = DependenciesDoubles(instanceFactory: stubInstanceFactory)
        
        let stubDelegate = StubSubscriptionDelegate(didReceiveEvent_expectedCallCount: 1)
        
        let sut = ConcreteSubscription(subscriptionType: subscriptionType,
                                       dependencies: dependencies,
                                       delegate: stubDelegate)
        
        let expectation = XCTestExpectation.Subscription.subscribe
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 0)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Call `subscribe` to progress `ConcreteSubscription.state` from `.notSubscribed` -> `.subscribingStageTwo`
        sut.subscribe(completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1) // <- Inceased by one
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1) // <- Inceased by one
    }
    
    func test_subscribe_whenSubscribingStageTwo_staysSubscribingStageTwoAndCompletionNotInvoked() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation)
            = setUp_subscribingStageTwo(forType: subscriptionType)
        
        let secondExpectation = XCTestExpectation.Subscription.subscribe
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `subscribe` is called when the `ConcreteSubscription.state` is `.subscribingStageTwo` this should:
        //      queue the `completion` handler to be called later (when the susbcription event returns)
        //      leave everything else unchanged
        
        sut.subscribe(completion: secondExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_subscribe_whenSubscribingStageTwoWithMultipleWaitingCompletions_staysSubscribingStageTwoAndCompletionNotInvoked() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(forType: subscriptionType)
        
        let thirdExpectation = XCTestExpectation.Subscription.subscribe
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertExpectationUnfulfilled(thirdExpectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `subscribe` is called when the `ConcreteSubscription.state` is `.subscribingStageTwo` this should:
        //      queue the `completion` handler to be called later (when the susbcription event returns)
        //      leave everything else unchanged
        
        sut.subscribe(completion: thirdExpectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertExpectationUnfulfilled(thirdExpectation)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_subscribe_whenSubscribed_staysSubscribedAndCompletionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user

        let (sut, stubInstance, stubInstanceFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType)
            
        let expectation = XCTestExpectation.Subscription.subscribe
        
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `subscribe` is called when the `ConcreteSubscription.state` is already `.subscribed` this should:
        //      invoked the delegates `didReceiveEvent` method
        //      invoked the `completion` handler immediately with `.success`
        //      leave everything else unchanged
        
        sut.subscribe(completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
    }
    
    
    // MARK: Incoming Event
    
    func test_incomingEvent_whenSubscribingStageTwo_subscribeCompletionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType)
        
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        //      invoked the delegates `didReceiveEvent` method
        //      invoke the waiting `completion` handler with `.success`
        
        stubInstance.fireOnEvent(jsonData: "{}".toJsonData())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1) // <- Inceased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEvent_whenSubscribingStageTwoWithMultipleWaitingCompletions_allSubscribeCompletionsInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(forType: subscriptionType)
        
        // Confirm setUp
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        //      invoked the delegates `didReceiveEvent` method
        //      invoke BOTH waiting `completion` handlers with `.success`
        
        stubInstance.fireOnEvent(jsonData: "{}".toJsonData())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        // Both expectations shoudld have been fulfilled with `.success`
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .success)
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .success)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1) // <-- increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEvent_whenSubscribed_callsDelegateDidReceiveEvent() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedEvent_expectedCallCount: 2)
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      invoked the delegates `didReceiveEvent` method
        
        stubInstance.fireOnEvent(jsonData: "{}".toJsonData())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 2) // <- Inceased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    // MARK: Incoming Error
    
    func test_incomingError_whenSubscribingStageTwo_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType,
                                        stubDelegate_didReceivedError_expectedCallCount: 1,
                                        stubResumableSubscription_end_expected: true)
        
        // Confirm setUp
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoked the delegates `didReceiveError` method
        //      invoke the waiting `completion` handler with `.failure`
        
        stubInstance.fireOnError(error: "Dummy Error Message")
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertExpectationFulfilledWithResult(expectation, .failure("Dummy Error Message"))
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Inceased by one
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingError_whenSubscribingStageTwoAndMultipleWaitingdCompletions_allSubscribeCompletionsInvokedWithFailured() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(
                forType: subscriptionType,
                stubDelegate_didReceivedError_expectedCallCount: 1,
                stubResumableSubscription_end_expected: true)
        
        // Confirm setUp
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoked the delegates `didReceiveError` method
        //      invoke BOTH waiting `completion` handlers with `.failure`
        
        stubInstance.fireOnError(error: "Dummy Error Message")
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        // Both expectations shoudld have been fulfilled with `.failure`
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .failure("Dummy Error Message"))
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .failure("Dummy Error Message"))
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <-- increased by one
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingError_whenSubscribed_callsDelegateDidReceiveError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubInstance, stubInstanceFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedError_expectedCallCount: 1,
                               stubResumableSubscription_end_expected: true)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        //      invoked the delegates `didReceiveError` method
        //      leave everything else unchanged
        
        stubInstance.fireOnError(error: "Dummy Error Message")
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Inceased by one
        XCTAssertEqual(stubInstanceFactory.makeInstance_actualCallCount, 1)
        XCTAssertEqual(stubInstance.subscribeWithResume_actualCallCount, 1)
        
    }
    
}
