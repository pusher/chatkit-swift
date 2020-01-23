import XCTest
@testable import PusherChatkit


class ConcreteStoreBroadcasterTests: XCTestCase {

    let stateA = State(
        currentUser: Internal.User(
            identifier: "alice",
            name: "Alice A"
        ),
        joinedRooms: []
    )

    let stateB = State(
        currentUser: Internal.User(
            identifier: "bob",
            name: "Bob B"
        ),
        joinedRooms: []
    )
    
    func test_didUpdateState_listenerRegistered_forwardsToListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())

        let _ = sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)
    }
    
    func test_didUpdateState_listenerUnregistered_listenerNotCalled() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())
        
        // TODO implement unregister
        let _ = sut.register(stubStoreListener)
        sut.unregister(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)

        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
    }
    
    func test_didUpdateState_listenerRegisteredTwice_forwardsOnlyOncePerUniqueListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())

        let _ = sut.register(stubStoreListener)
        let _ = sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)
    }
    
    func test_didUpdateState_multipleListenersMutlipleActions_forwardsAsAppropriate() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener1 = StubStoreListener(didUpdateState_expectedCallCount: 2)
        let stubStoreListener2 = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener1.didUpdateState_callCount, 0)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initialState1 = sut.register(stubStoreListener1)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(initialState1, State.emptyState)
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener1.didUpdateState_callCount, 0)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener1.didUpdateState_callCount, 1)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initialState2 = sut.register(stubStoreListener2)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(initialState2, stateA)
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener1.didUpdateState_callCount, 1)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateB)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, stateB)
        XCTAssertEqual(stubStoreListener1.didUpdateState_callCount, 2)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, stateB)
        XCTAssertEqual(stubStoreListener2.didUpdateState_callCount, 1)
    }
}
