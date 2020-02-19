import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteStoreBroadcasterTests: XCTestCase {
    
    let stateA = VersionedState(
        chatState: ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: .empty,
            users: UserListState(
                users: [
                    "alice" : .populated(
                        identifier: "alice",
                        name: "Alice A"
                    )
                ]
            )
        ),
        version: 1,
        signature: .initialState
    )
    
    let stateB = VersionedState(
        chatState: ChatState(
            currentUser: .populated(
                identifier: "bob",
                name: "Bob B"
            ),
            joinedRooms: .empty,
            users: UserListState(
                users: [
                    "bob" : .populated(
                        identifier: "bob",
                        name: "Bob B"
                    )
                ]
            )
        ),
        version: 1,
        signature: .initialState
    )
    
    func test_register_withListenerThatIsNotCurrentlyRegistered_returnsStateFromStore() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: stateA)
        let stubStoreListener = StubStoreListener()
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initialState = sut.register(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(initialState, stateA)
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_register_withListenerThatIsCurrentlyRegistered_returnsStateFromStore() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: stateA)
        let stubStoreListener = StubStoreListener()
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        _ = sut.register(stubStoreListener)
        // TODO:
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initialState = sut.register(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(initialState, stateA)
        XCTAssertEqual(stubStore.state_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_unregister_withListenerThatIsNotCurrentlyRegistered_success() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: stateA)
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 0)
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        XCTAssertEqual(stubStore.state_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.unregister(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_unregister_withListenerThatIsCurrentlyRegistered_success() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: stateA)
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 0)
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        _ = sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.unregister(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_didUpdateState_withListenerRegistered_forwardsToListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial)
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        _ = sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
    }
    
    func test_didUpdateState_withListenerThatHasUnregistered_listenerNotCalled() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial)
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        _ = sut.register(stubStoreListener)
        sut.unregister(stubStoreListener)
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_didUpdateState_withListenerRegisteredTwice_forwardsOnlyOncePerUniqueListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial)
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        _ = sut.register(stubStoreListener)
        _ = sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStore.state_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
    }
    
    func test_didUpdateState_withMultipleListenersAndMutlipleActions_forwardsAsAppropriate() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStore = StubStore(state_toReturn: .initial)
        let stubStoreListener1 = StubStoreListener(didUpdateState_expectedCallCount: 2)
        let stubStoreListener2 = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteStoreBroadcaster(dependencies: dependencies)
        
        XCTAssertEqual(stubStore.state_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        _ = sut.register(stubStoreListener1)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateA)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        _ = sut.register(stubStoreListener2)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, stateA)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.store(DummyStore(), didUpdateState: stateB)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.state_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, stateB)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, stateB)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 1)
    }
}
