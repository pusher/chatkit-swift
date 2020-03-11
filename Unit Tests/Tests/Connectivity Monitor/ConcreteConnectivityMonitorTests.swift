import XCTest
import TestUtilities
@testable import PusherChatkit

class ConcreteConnectivityMonitorTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_init_withConnectionStatePresentInAuxiliaryState_returnsConnectionStateFromAuxiliaryState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let connectionState: ConnectionState = .connected
        let state = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(
                subscriptions: [
                    subscriptionType : connectionState
                ]
            ),
            version: 1,
            signature: .initialState
        )
        
        let stubStore = StubStore(register_stateToReturn: state,
                                  unregister_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedConnectionState = connectionState
        
        XCTAssertEqual(sut.connectionState, expectedConnectionState)
    }
    
    func test_init_withConnectionStateNotPresentInAuxiliaryState_returnsClosedConnectionState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let state: VersionedState = .initial
        
        let stubStore = StubStore(register_stateToReturn: state,
                                  unregister_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedConnectionState: ConnectionState = .closed(error: nil)
        
        XCTAssertEqual(sut.connectionState, expectedConnectionState)
    }
    
    func test_init_registersAsStoreListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let state: VersionedState = .initial
        
        let stubStore = StubStore(register_stateToReturn: state,
                                  unregister_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.register_actualCallCount, 1)
        XCTAssertTrue(stubStore.register_listenerLastReceived === sut)
    }
    
    func test_deinit_unregistersAsStoreListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let state: VersionedState = .initial
        
        let stubStore = StubStore(register_stateToReturn: state,
                                  unregister_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        _ = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.unregister_actualCallCount, 1)
    }
    
    func test_didUpdateState_withModifiedConnectionState_shouldReportNewConnectionState() {
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let connectionState: ConnectionState = .connected
        
        let initialState: VersionedState = .initial
        
        let modifiedState = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(subscriptions: [
                subscriptionType : connectionState
            ]),
            version: 1,
            signature: .subscriptionStateUpdated
        )
        
        let stubStore = StubStore(register_stateToReturn: initialState,
                                  unregister_expectedCallCount: 1)
        let stubDelegate = StubConnectivityMonitorDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.connectionState, ConnectionState.closed(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(modifiedState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedConnectionState = connectionState
        
        XCTAssertEqual(sut.connectionState, expectedConnectionState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didUpdateState_stateLastReceived, expectedConnectionState)
    }
    
    func test_didUpdateState_withUnmodifiedConnectionState_shouldNotReportNewConnectionState() {
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let subscriptionType: SubscriptionType = .user
        let connectionState: ConnectionState = .closed(error: nil)
        
        let initialState: VersionedState = .initial
        
        let modifiedState = VersionedState(
            chatState: .empty,
            auxiliaryState: AuxiliaryState(subscriptions: [
                subscriptionType : connectionState
            ]),
            version: 1,
            signature: .subscriptionStateUpdated
        )
        
        let stubStore = StubStore(register_stateToReturn: initialState,
                                  unregister_expectedCallCount: 1)
        let stubDelegate = StubConnectivityMonitorDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.connectionState, ConnectionState.closed(error: nil))
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(modifiedState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedConnectionState = connectionState
        
        XCTAssertEqual(sut.connectionState, expectedConnectionState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
}
