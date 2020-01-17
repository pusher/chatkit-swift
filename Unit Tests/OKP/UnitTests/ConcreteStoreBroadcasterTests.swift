import XCTest
@testable import PusherChatkit


class ConcreteStoreBroadcasterTests: XCTestCase {

    let state = State(
        currentUser: Internal.User(
            identifier: "viv",
            name: "Vivan"
        ),
        joinedRooms: []
    )
    
    func test_storeCallback_listenerRegistered_forwardsToListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())

        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, state)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)
    }
    
    func test_storeCallback_listenerUnregisters_listenerNotCalled() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())
        
        // TODO implement unregister
        // sut.register(stubStoreListener)
        // sut.unregister(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)

        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
    }
    
    func test_storeCallback_listenerRegisteredTwice_forwardsOnlyOncePerUniqueListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())

        sut.register(stubStoreListener)
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, state)
        XCTAssertEqual(stubStoreListener.didUpdateState_callCount, 1)
    }
    
    func test_storeCallback_multipleListeners_forwardsToAllListeners() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListenerA = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let stubStoreListenerB = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let sut = ConcreteStoreBroadcaster(dependencies: DependenciesDoubles())

        sut.register(stubStoreListenerA)
        sut.register(stubStoreListenerB)
        
        XCTAssertEqual(stubStoreListenerA.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListenerA.didUpdateState_callCount, 0)
        
        XCTAssertEqual(stubStoreListenerB.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListenerB.didUpdateState_callCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListenerA.didUpdateState_stateLastReceived, state)
        XCTAssertEqual(stubStoreListenerA.didUpdateState_callCount, 1)
        
        XCTAssertEqual(stubStoreListenerB.didUpdateState_stateLastReceived, state)
        XCTAssertEqual(stubStoreListenerB.didUpdateState_callCount, 1)
    }
}
