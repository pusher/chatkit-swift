import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteStoreTests: XCTestCase {
    
    // MARK: - Properties
    
    let stateA = VersionedState(
        chatState: ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: .empty,
            users: UserListState(
                elements: [
                    .populated(
                        identifier: "alice",
                        name: "Alice A"
                    )
                ]
            )
        ),
        auxiliaryState: .empty,
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
                elements: [
                    .populated(
                        identifier: "bob",
                        name: "Bob B"
                    )
                ]
            )
        ),
        auxiliaryState: .empty,
        version: 1,
        signature: .initialState
    )
    
    // MARK: - Tests
    
    func test_init_stateStartsWithInitialState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteStore(dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(sut.state, .initial)
    }
    
    func test_dispatch_withActionThatDoesChangeInternalState_stateIsUpdated() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState: VersionedState = .initial
        
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        
        XCTAssertEqual(sut.state, .initial)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = InitialStateAction(
            event: Wire.Event.InitialState(
                currentUser: Wire.User(
                    identifier: "alice",
                    name: "Alice A",
                    avatarURL: nil,
                    customData: nil,
                    createdAt: Date.distantPast,
                    updatedAt: Date.distantFuture,
                    deletedAt: nil
                ),
                rooms: [],
                readStates: [],
                memberships: []
            )
        )
        
        sut.dispatch(action: action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_dispatch_withActionThatDoesChangeInternalState_delegateTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "alice",
                    name: "Alice A"
                ),
                joinedRooms: .empty,
                users: UserListState(
                    elements: [
                        .populated(
                            identifier: "alice",
                            name: "Alice A"
                        )
                    ]
                )
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState)
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = InitialStateAction(
            event: Wire.Event.InitialState(
                currentUser: Wire.User(
                    identifier: "alice",
                    name: "Alice A",
                    avatarURL: nil,
                    customData: nil,
                    createdAt: Date.distantPast,
                    updatedAt: Date.distantFuture,
                    deletedAt: nil
                ),
                rooms: [],
                readStates: [],
                memberships: []
            )
        )
        
        sut.dispatch(action: action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, expectedState)
    }
    
    func test_dispatch_withActionThatDoesNotChangeInternalState_stateIsUnchanged() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState: VersionedState = .initial
        
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        
        XCTAssertEqual(sut.state, .initial)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = RemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "not-a-known-room"
            )
        )
        
        sut.dispatch(action: action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_dispatch_withActionThatDoesNotChangeInternalState_delegateNotTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 2)
        
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: .initial, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = RemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "not-a-known-room"
            )
        )
        
        sut.dispatch(action: action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0) // <--- Call count has NOT increased!
    }
    
    func test_dispatch_usesReductionManager_reduceTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState: VersionedState = .initial
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = InitialStateAction(
            event: Wire.Event.InitialState(
                currentUser: Wire.User(
                    identifier: "alice",
                    name: "Alice A",
                    avatarURL: nil,
                    customData: nil,
                    createdAt: Date.distantPast,
                    updatedAt: Date.distantFuture,
                    deletedAt: nil
                ),
                rooms: [],
                readStates: [],
                memberships: []
            )
        )
        
        sut.dispatch(action: action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubMasterReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(stubMasterReducer.reduce_actionLastReceived as? InitialStateAction, action)
        XCTAssertEqual(stubMasterReducer.reduce_stateLastReceived, .initial)
    }
    
    func test_register_withListenerThatIsNotCurrentlyRegistered_returnsStateFromStore() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener()
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: self.stateA, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initialState = sut.register(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(initialState, self.stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_register_withListenerThatIsCurrentlyRegistered_returnsStateFromStore() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener()
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: self.stateA, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let initialState = sut.register(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(initialState, self.stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_unregister_withListenerThatIsNotCurrentlyRegistered_success() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 0)
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: self.stateA, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.unregister(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_unregister_withListenerThatIsCurrentlyRegistered_success() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 0)
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: self.stateA, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.unregister(stubStoreListener)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_didUpdateState_withListenerRegistered_forwardsToListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: .initial, reduce_expectedCallCount: 2)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubMasterReducer.reduce_stateToReturn = self.stateA
        sut.dispatch(action: FakeAction())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, self.stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
    }
    
    func test_didUpdateState_withListenerThatHasUnregistered_listenerNotCalled() {

        /******************/
        /*---- GIVEN -----*/
        /******************/

        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: .initial, reduce_expectedCallCount: 2)

        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)

        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        sut.register(stubStoreListener)
        sut.unregister(stubStoreListener)

        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)

        /******************/
        /*----- WHEN -----*/
        /******************/

        stubMasterReducer.reduce_stateToReturn = self.stateA
        sut.dispatch(action: FakeAction())

        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
    }
    
    func test_didUpdateState_withListenerRegisteredTwice_forwardsOnlyOncePerUniqueListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: .initial, reduce_expectedCallCount: 2)

        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        sut.register(stubStoreListener)
        sut.register(stubStoreListener)
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubMasterReducer.reduce_stateToReturn = self.stateA
        sut.dispatch(action: FakeAction())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener.didUpdateState_stateLastReceived, self.stateA)
        XCTAssertEqual(stubStoreListener.didUpdateState_actualCallCount, 1)
    }
    
    func test_didUpdateState_withMultipleListenersAndMutlipleActions_forwardsAsAppropriate() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreListener1 = StubStoreListener(didUpdateState_expectedCallCount: 2)
        let stubStoreListener2 = StubStoreListener(didUpdateState_expectedCallCount: 1)
        let stubMasterReducer = StubReducer<Reducer.Master>(reduce_stateToReturn: .initial, reduce_expectedCallCount: 3)

        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies)
        sut.dispatch(action: FakeAction())
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.register(stubStoreListener1)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 0)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubMasterReducer.reduce_stateToReturn = self.stateA
        sut.dispatch(action: FakeAction())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, self.stateA)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        sut.register(stubStoreListener2)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, self.stateA)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubMasterReducer.reduce_stateToReturn = self.stateB
        sut.dispatch(action: FakeAction())
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreListener1.didUpdateState_stateLastReceived, self.stateB)
        XCTAssertEqual(stubStoreListener1.didUpdateState_actualCallCount, 2)
        XCTAssertEqual(stubStoreListener2.didUpdateState_stateLastReceived, self.stateB)
        XCTAssertEqual(stubStoreListener2.didUpdateState_actualCallCount, 1)
    }
    
}
