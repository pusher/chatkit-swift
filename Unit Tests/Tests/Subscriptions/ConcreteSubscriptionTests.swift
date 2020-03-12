import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteSubscriptionTests: XCTestCase {
    
    private enum ConcreteSubscriptionAssertableState {
        
        /*
         Note: `subscribingStageOne` and `subscribingStageTwo` are required because when calling `instanceWrapper.subscribeWithResume` its possible that the `onError` closure might fire BEFORE the method itself has returned. In that instance we need to know within the `onError` closure that we were in the process of subscribing so we set the state to `subscribingStageOne` beforehand to indicate this state and it also holds reference to the completion handlers that are in need of invocation.
         
         So in summary:
            subscribingStageOne: `subscribeWithResume` has been invoked but has not returned.
            subscribingStageTwo: `subscribeWithResume` has been invoked and has returned but `onOpen` has not yet fired.
            subscribed: `subscribeWithResume` has been invoked and has returned and `onOpen` has fired.
         */
        
        case notSubscribed
        case subscribingStageOne
        case subscribingStageTwo
        case subscribed
    }
    
    private func XCTAssertEqualState(_ actualState: ConcreteSubscription.State,
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

    private func setUp_notSubscribed(forType subscriptionType: SubscriptionType,
                                     stubStore_dispatch_expectedCallCount: UInt = 1,
                                     stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
                                     stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
                                     stubResumableSubscription_terminate_expected: Bool? = nil,
                                     file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubStore, StubInstanceWrapper, StubInstanceWrapperFactory, StubSubscriptionDelegate) {
            
            let instanceType: InstanceType = .subscription(subscriptionType)
            
            let stubStore = StubStore(
                dispatch_expectedCallCount: stubStore_dispatch_expectedCallCount,
                file: file, line: line
            )
            
            let stubInstanceWrapper = StubInstanceWrapper(
                subscribeWithResume_outcomes: [.wait],
                resumableSubscription_terminate_expected: stubResumableSubscription_terminate_expected ?? false,
                file: file, line: line
            )
            
            let stubInstanceWrapperFactory = StubInstanceWrapperFactory(makeInstanceWrapper_expectedTypesAndInstanceWrappersToReturn:
                [(instanceType: instanceType, instanceWrapper: stubInstanceWrapper)], file: file, line: line)
            
            let dependencies = DependenciesDoubles(store: stubStore, instanceWrapperFactory: stubInstanceWrapperFactory, file: file, line: line)
            
            let stubDelegate = StubSubscriptionDelegate(
                didReceiveEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount ?? 1,
                didReceiveError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount ?? 0,
                file: file, line: line
            )
            
            let sut = ConcreteSubscription(subscriptionType: subscriptionType,
                                           dependencies: dependencies,
                                           delegate: stubDelegate)
            
            XCTAssertEqualState(sut.state, .notSubscribed, file: file, line: line)
            XCTAssertEqual(stubStore.dispatch_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 0, file: file, line: line)
            
            // Current state
            // `ConcreteSubscription.state` is `.subscribingStageTwo`
            // `completion` handler has NOT been invoked
            
            return (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
    }
    
    private func setUp_subscribingStageTwo(forType subscriptionType: SubscriptionType,
                                           stubStore_dispatch_expectedCallCount: UInt = 2,
                                           stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
                                           stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
                                           stubResumableSubscription_terminate_expected: Bool? = nil,
                                           file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubStore, StubInstanceWrapper, StubInstanceWrapperFactory, StubSubscriptionDelegate, XCTestExpectation.Expectation<VoidResult>) {
            
            let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
                = setUp_notSubscribed(forType: subscriptionType,
                                      stubStore_dispatch_expectedCallCount: stubStore_dispatch_expectedCallCount,
                                      stubDelegate_didReceivedEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount,
                                      stubDelegate_didReceivedError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount,
                                      stubResumableSubscription_terminate_expected: stubResumableSubscription_terminate_expected,
                                      file: file, line: line)

            let expectation = XCTestExpectation.Subscription.subscribe
            
            sut.subscribe(completion: expectation.handler)
            
            XCTAssertEqualState(sut.state, .subscribingStageTwo, file: file, line: line)
            XCTAssertExpectationUnfulfilled(expectation, file: file, line: line)
            XCTAssertEqual(stubStore.dispatch_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1, file: file, line: line)
            
            return (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
    }
    
    private func setUp_subscribingStageTwoWithMultipleWaitingCompletions(
        forType subscriptionType: SubscriptionType,
        stubStore_dispatch_expectedCallCount: UInt = 2,
        stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
        stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
        stubResumableSubscription_terminate_expected: Bool? = nil,
        file: StaticString = #file, line: UInt = #line
    )
        -> (ConcreteSubscription, StubStore, StubInstanceWrapper, StubInstanceWrapperFactory, StubSubscriptionDelegate, XCTestExpectation.Expectation<VoidResult>, XCTestExpectation.Expectation<VoidResult>) {

        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation)
            = setUp_subscribingStageTwo(forType: subscriptionType,
                                        stubStore_dispatch_expectedCallCount: stubStore_dispatch_expectedCallCount,
                                        stubDelegate_didReceivedEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount,
                                        stubDelegate_didReceivedError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount,
                                        stubResumableSubscription_terminate_expected: stubResumableSubscription_terminate_expected,
                                        file: file, line: line)

        let secondExpectation = XCTestExpectation.Subscription.subscribe
            
        sut.subscribe(completion: secondExpectation.handler)
            
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1, file: file, line: line)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)

        return (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
    }
            
    private func setUp_subscribed(forType subscriptionType: SubscriptionType,
                                  stubStore_dispatch_expectedCallCount: UInt = 3,
                                  stubDelegate_didReceivedEvent_expectedCallCount: UInt? = nil,
                                  stubDelegate_didReceivedError_expectedCallCount: UInt? = nil,
                                  stubResumableSubscription_terminate_expected: Bool? = nil,
                                  file: StaticString = #file, line: UInt = #line)
        -> (ConcreteSubscription, StubStore, StubInstanceWrapper, StubInstanceWrapperFactory, StubSubscriptionDelegate) {
            
            let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
                = setUp_subscribingStageTwo(forType: subscriptionType,
                                            stubStore_dispatch_expectedCallCount: stubStore_dispatch_expectedCallCount,
                                            stubDelegate_didReceivedEvent_expectedCallCount: stubDelegate_didReceivedEvent_expectedCallCount,
                                            stubDelegate_didReceivedError_expectedCallCount: stubDelegate_didReceivedError_expectedCallCount,
                                            stubResumableSubscription_terminate_expected:
                                                stubResumableSubscription_terminate_expected,
                                            file: file, line: line)
            
            let jsonData = "{}".toJsonData()
            stubInstanceWrapper.fireOnEvent(jsonData: jsonData)
            
            wait(for: [expectation], timeout: expectation.timeout)
            
            XCTAssertEqualState(sut.state, .subscribed, file: file, line: line)
            XCTAssertExpectationFulfilledWithResult(expectation, .success, file: file, line: line)
            XCTAssertEqual(stubStore.dispatch_actualCallCount, 2, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0, file: file, line: line)
            XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1, file: file, line: line)
            XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1, file: file, line: line)
            
            return (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
    }
    
    // MARK: subscribe(completion:)
    
    func test_subscribe_whenNotSubscribed_becomesSubscribingStageTwoAndCompletionNotInvoked() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user

        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate) = setUp_notSubscribed(forType: subscriptionType)
        
        let expectation = XCTestExpectation.Subscription.subscribe
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `subscribe` is called when the `ConcreteSubscription.state` is `.notSubscribed` this should:
        //      invoke the instanceWrapperFactory to make an `InstanceWrapper`
        //      call `subscribeWithResume` on the new `InstanceWrapper`
        //      move `ConcreteSubscription.state` from `.notSubscribed` -> `.subscribingStageTwo`
        //      queue the `completion` handler to be called later (when the susbcription event returns)
        
        sut.subscribe(completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .subscribing)
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1) // <- Increased by one
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1) // <- Increased by one
    }
    
    func test_subscribe_whenSubscribingStageTwo_staysSubscribingStageTwoAndCompletionNotInvoked() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation)
            = setUp_subscribingStageTwo(forType: subscriptionType)
        
        let secondExpectation = XCTestExpectation.Subscription.subscribe
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
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
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_subscribe_whenSubscribingStageTwoWithMultipleWaitingCompletions_staysSubscribingStageTwoAndCompletionNotInvoked() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(forType: subscriptionType)
        
        let thirdExpectation = XCTestExpectation.Subscription.subscribe
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertExpectationUnfulfilled(thirdExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
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
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_subscribe_whenSubscribed_staysSubscribedAndCompletionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user

        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType)
            
        let expectation = XCTestExpectation.Subscription.subscribe
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `subscribe` is called when the `ConcreteSubscription.state` is already `.subscribed` this should:
        //      invoke the delegates `didReceiveEvent` method
        //      invoked the `completion` handler immediately with `.success`
        //      leave everything else unchanged
        
        sut.subscribe(completion: expectation.handler)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
    }
    
    // MARK: unsubscribe()
    
    func test_unsubscribe_whenNotSubscribed_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user

        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate) = setUp_notSubscribed(forType: subscriptionType)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `unsubscribe` is called when the `ConcreteSubscription.state` is `.notSubscribed` this should:
        //      leave everything else unchanged (since we're already unsubscribed)
        
        sut.unsubscribe()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 0)
    }
    
    func test_unsubscribe_whenSubscribingStageTwo_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType,
                                        stubDelegate_didReceivedError_expectedCallCount: 1,
                                        stubResumableSubscription_terminate_expected: true)
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `unsubscribe` is called when the `ConcreteSubscription.state` is `.subscribingStageTwo` this should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      invoke the waiting `completion` handler with `.failure`
        
        sut.unsubscribe()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedError = SubscriptionError.unsubscribeCalledWhileSubscribingError
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(expectation, .failure(expectedError))
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Increased by one
        XCTAssertEqualError(stubDelegate.didReceiveError_errorLastReceived, expectedError)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
    }
    
    func test_unsubscribe_whenSubscribingStageTwoWithMultipleWaitingCompletions_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(
                forType: subscriptionType,
                stubDelegate_didReceivedError_expectedCallCount: 1,
                stubResumableSubscription_terminate_expected: true
            )
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // If `unsubscribe` is called when the `ConcreteSubscription.state` is `.subscribingStageTwo` this should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      invoke BOTH waiting `completion` handlers with `.failure`
        
        sut.unsubscribe()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedError = SubscriptionError.unsubscribeCalledWhileSubscribingError
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .failure(expectedError))
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .failure(expectedError))
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Increased by one
        XCTAssertEqualError(stubDelegate.didReceiveError_errorLastReceived, expectedError)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
    }
    
    func test_unsubscribe_whenSubscribed_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedError_expectedCallCount: 1,
                               stubResumableSubscription_terminate_expected: true)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        
        // If `unsubscribe` is called when the `ConcreteSubscription.state` is `.subscribed` this should:
        //      move `ConcreteSubscription.state` from `.subscribed` -> `.notSubscribed`
        //      leave everything else unchanged
        
        sut.unsubscribe()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 3) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
    }
    
    // MARK: Incoming Event (with valid JSON)
    
    func test_incomingEventWithValidJson_whenSubscribingStageTwo_subscribeCompletionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType)
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        //      invoke the delegates `didReceiveEvent` method
        //      invoke the waiting `completion` handler with `.success`
        
        let validJsonData = "{}".toJsonData()
        stubInstanceWrapper.fireOnEvent(jsonData: validJsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .subscribed)
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1) // <- Increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEventWithValidJson_whenSubscribingStageTwoWithMultipleWaitingCompletions_allSubscribeCompletionsInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(forType: subscriptionType)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        //      invoke the delegates `didReceiveEvent` method
        //      invoke BOTH waiting `completion` handlers with `.success`
        
        let validJsonData = "{}".toJsonData()
        stubInstanceWrapper.fireOnEvent(jsonData: validJsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .subscribed)
        
        // Both expectations shoudld have been fulfilled with `.success`
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .success)
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .success)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1) // <-- increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEvent_whenSubscribed_callsDelegateDidReceiveEvent() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedEvent_expectedCallCount: 2)
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      invoke the delegates `didReceiveEvent` method
        
        let validJsonData = "{}".toJsonData()
        stubInstanceWrapper.fireOnEvent(jsonData: validJsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    // MARK: Incoming Event (with invalid JSON)
    
    func test_incomingEventWithInvalidJson_whenSubscribingStageTwo_subscribeCompletionInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType)
        
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        //      invoke the delegates `didReceiveEvent` method
        //      invoke the waiting `completion` handler with `.success`
        
        let invalidJsonData = "{ \"not valid\" }".toJsonData(validate: false)
        stubInstanceWrapper.fireOnEvent(jsonData: invalidJsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .subscribed)
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationFulfilledWithResult(expectation, .success)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1) // <- Increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEventWithInvalidJson_whenSubscribingStageTwoWithMultipleWaitingCompletions_allSubscribeCompletionsInvokedWithSuccess() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(forType: subscriptionType)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.subscribed`
        //      invoke the delegates `didReceiveEvent` method
        //      invoke BOTH waiting `completion` handlers with `.success`
        
        let invalidJsonData = "{ \"not valid\" }".toJsonData(validate: false)
        stubInstanceWrapper.fireOnEvent(jsonData: invalidJsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .subscribed)
        
        // Both expectations shoudld have been fulfilled with `.success`
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .success)
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .success)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1) // <-- increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEventWithInvalidJson_whenSubscribed_callsDelegateDidReceiveEvent() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedEvent_expectedCallCount: 2)
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Event*, which should:
        //      invoke the delegates `didReceiveEvent` method
        
        let invalidJsonData = "{ \"not valid\" }".toJsonData(validate: false)
        stubInstanceWrapper.fireOnEvent(jsonData: invalidJsonData)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    // MARK: Incoming Error
    
    func test_incomingError_whenSubscribingStageTwo_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType,
                                        stubDelegate_didReceivedError_expectedCallCount: 1,
                                        stubResumableSubscription_terminate_expected: true)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      invoke the waiting `completion` handler with `.failure`
        
        stubInstanceWrapper.fireOnError(error: FakeError.firstError)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(expectation, .failure(FakeError.firstError))
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Increased by one
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingError_whenSubscribingStageTwoAndMultipleWaitingdCompletions_allSubscribeCompletionsInvokedWithFailured() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(
                forType: subscriptionType,
                stubDelegate_didReceivedError_expectedCallCount: 1,
                stubResumableSubscription_terminate_expected: true
            )
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      invoke BOTH waiting `completion` handlers with `.failure`
        
        stubInstanceWrapper.fireOnError(error: FakeError.firstError)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        // Both expectations shoudld have been fulfilled with `.failure`
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .failure(FakeError.firstError))
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .failure(FakeError.firstError))
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <-- increased by one
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingError_whenSubscribed_callsDelegateDidReceiveError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedError_expectedCallCount: 1,
                               stubResumableSubscription_terminate_expected: true)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *Error*, which should:
        //      invoke the delegates `didReceiveError` method
        //      leave everything else unchanged
        
        stubInstanceWrapper.fireOnError(error: FakeError.firstError)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Increased by one
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    // MARK: Incoming End
    
    func test_incomingEnd_whenSubscribingStageTwo_() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, expectation)
            = setUp_subscribingStageTwo(forType: subscriptionType,
                                        stubDelegate_didReceivedError_expectedCallCount: 1,
                                        stubResumableSubscription_terminate_expected: true)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(expectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *End*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      invoke the waiting `completion` handler with `.failure`
        
        stubInstanceWrapper.fireOnEnd()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        wait(for: [expectation], timeout: expectation.timeout)
        
        let expectedError = SubscriptionError.onEndReceivedWhileSubscribingError
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(expectation, .failure(expectedError))
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Increased by one
        XCTAssertEqualError(stubDelegate.didReceiveError_errorLastReceived, expectedError)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEnd_whenSubscribingStageTwoAndMultipleWaitingdCompletions_allSubscribeCompletionsInvokedWithFailured() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate, firstExpectation, secondExpectation)
            = setUp_subscribingStageTwoWithMultipleWaitingCompletions(
                forType: subscriptionType,
                stubDelegate_didReceivedError_expectedCallCount: 1,
                stubResumableSubscription_terminate_expected: true
            )
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribingStageTwo)
        XCTAssertExpectationUnfulfilled(firstExpectation)
        XCTAssertExpectationUnfulfilled(secondExpectation)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *End*, which should:
        //      move `ConcreteSubscription.state` from `.subscribingStageTwo` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      invoke BOTH waiting `completion` handlers with `.failure`
        
        stubInstanceWrapper.fireOnEnd()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        // Wait for both expecations to become fulfilled
        wait(for: [firstExpectation, secondExpectation],
             timeout: max(firstExpectation.timeout, secondExpectation.timeout))
        
        let expectedError = SubscriptionError.onEndReceivedWhileSubscribingError
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        // Both expectations shoudld have been fulfilled with `.failure`
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertExpectationFulfilledWithResult(firstExpectation, .failure(expectedError))
        XCTAssertExpectationFulfilledWithResult(secondExpectation, .failure(expectedError))
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 0)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <-- increased by one
        XCTAssertEqualError(stubDelegate.didReceiveError_errorLastReceived, expectedError)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
    func test_incomingEnd_whenSubscribed_callsDelegateDidReceiveError() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        
        let (sut, stubStore, stubInstanceWrapper, stubInstanceWrapperFactory, stubDelegate)
            = setUp_subscribed(forType: subscriptionType,
                               stubDelegate_didReceivedError_expectedCallCount: 1,
                               stubResumableSubscription_terminate_expected: true)
        
        // Confirm setUp
        XCTAssertEqualState(sut.state, .subscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 0)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        // Emulate the firing of a subscription *End*, which should:
        //      move `ConcreteSubscription.state` from `.subscribed` -> `.notSubscribed`
        //      invoke the delegates `didReceiveError` method
        //      leave everything else unchanged
        
        stubInstanceWrapper.fireOnEnd()
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedError = SubscriptionError.onEndReceivedWhileSubscribedError
        let expectedAction = SubscriptionStateUpdatedAction(type: subscriptionType, state: .notSubscribed)
        
        XCTAssertEqualState(sut.state, .notSubscribed)
        XCTAssertEqual(stubStore.dispatch_actualCallCount, 3) // <- Increased by one
        XCTAssertEqual(stubStore.dispatch_lastReceived as? SubscriptionStateUpdatedAction, expectedAction)
        XCTAssertEqual(stubDelegate.didReceiveEvent_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didReceiveError_actualCallCount, 1) // <- Increased by one
        XCTAssertEqualError(stubDelegate.didReceiveError_errorLastReceived, expectedError)
        XCTAssertEqual(stubInstanceWrapperFactory.makeInstanceWrapper_actualCallCount, 1)
        XCTAssertEqual(stubInstanceWrapper.subscribeWithResume_actualCallCount, 1)
        
    }
    
}
