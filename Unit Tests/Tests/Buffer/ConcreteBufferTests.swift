import XCTest
import TestUtilities
@testable import PusherChatkit

class ConcreteBufferTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_init_withIncompleteState_hasNilCurrentState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState: VersionedState = .initial
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasCompleteSubstate_defaultValueToReturn: false)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(sut.currentState)
    }
    
    func test_init_withCompleteState_hasCurrentState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState: VersionedState = .initial
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasCompleteSubstate_defaultValueToReturn: true)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = initialState
        
        XCTAssertEqual(sut.currentState, expectedState)
    }
    
    func test_init_registersAsStoreListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState: VersionedState = .initial
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasCompleteSubstate_defaultValueToReturn: true)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.register_actualCallCount, 1)
        XCTAssertTrue(stubStore.register_listenerLastReceived === sut)
    }
    
    func test_init_withInitialStateThatsCompleteWithRelevantSignature_currentStateIsSet() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_defaultValueToReturn: true,
                                         hasCompleteSubstate_defaultValueToReturn: true,
                                         hasRelevantSignature_defaultValueToReturn: true)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = initialState
        
        XCTAssertEqual(sut.currentState, expectedState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
    func test_init_withInitialStateThatsCompleteWithIrrelevantSignature_currentStateIsSet() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_defaultValueToReturn: true,
                                         hasCompleteSubstate_defaultValueToReturn: true,
                                         hasRelevantSignature_defaultValueToReturn: false)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = initialState
        
        XCTAssertEqual(sut.currentState, expectedState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
    func test_init_withInitialStateThatsIncompleteWithRelevantSignature_currentStateRemainsNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_defaultValueToReturn: true,
                                         hasCompleteSubstate_defaultValueToReturn: false,
                                         hasRelevantSignature_defaultValueToReturn: true)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(sut.currentState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
    func test_init_withInitialStateThatsIncompleteWithIrrelevantSignature_currentStateRemainsNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_defaultValueToReturn: true,
                                         hasCompleteSubstate_defaultValueToReturn: false,
                                         hasRelevantSignature_defaultValueToReturn: false)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(sut.currentState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
    func test_deinit_unregistersAsStoreListener() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState: VersionedState = .initial
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasCompleteSubstate_defaultValueToReturn: true)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        _ = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStore.unregister_actualCallCount, 1)
    }
    
    func test_didUpdateState_withIncompleteInitialState_shouldReportStateAfterSupplementation() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: ChatState(
                currentUser: .partial(
                    identifier: "test-user-identifier"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .unsigned
        )
        
        let supplementingState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier",
                    name: "test-user-name"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 2,
            signature: .unsigned
        )
        
        let supplementedInitialState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier",
                    name: "test-user-name"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .unsigned
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_valuesToReturn: [initialState : false,
                                                                              supplementingState : true,
                                                                              supplementedInitialState : false],
                                         hasCompleteSubstate_valuesToReturn: [initialState : false,
                                                                              supplementingState : true,
                                                                              supplementedInitialState : true],
                                         hasRelevantSignature_defaultValueToReturn: true)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 2)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertNil(sut.currentState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(supplementingState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = supplementingState
        
        XCTAssertEqual(sut.currentState, expectedState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 2)
        XCTAssertEqual(stubDelegate.didUpdateState_stateLastReceived, supplementingState)
    }
    
    func test_didUpdateState_withEmptyQueue_shouldReportCompleteSubsequentStateWithoutEnqueueing() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier",
                    name: "test-user-name"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .unsigned
        )
        
        let subsequentState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier",
                    name: "test-user-name"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 2,
            signature: .unsigned
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_valuesToReturn: [initialState : false,
                                                                              subsequentState : true],
                                         hasCompleteSubstate_defaultValueToReturn: true,
                                         hasRelevantSignature_defaultValueToReturn: true)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.currentState, initialState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(subsequentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = subsequentState
        
        XCTAssertEqual(sut.currentState, expectedState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubDelegate.didUpdateState_stateLastReceived, subsequentState)
    }
    
    func test_didUpdateState_withNonEmptyQueue_shouldNotReportCompleteSubsequentStateWhenStateSupplementationIsNotPossible() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier-1",
                    name: "test-user-name-1"
                ),
                joinedRooms: .empty,
                users: UserListState(
                    elements: [
                        .populated(
                            identifier: "test-user-identifier-1",
                            name: "test-user-name-1"
                        ),
                        .partial(
                            identifier: "test-user-identifier-2"
                        )
                    ]
                )
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .unsigned
        )
        
        let subsequentState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier-1",
                    name: "test-user-name-1"
                ),
                joinedRooms: .empty,
                users: UserListState(
                    elements: [
                        .populated(
                            identifier: "test-user-identifier-1",
                            name: "test-user-name-1"
                        ),
                        .populated(
                            identifier: "test-user-identifier-3",
                            name: "test-user-name-3"
                        )
                    ]
                )
            ),
            auxiliaryState: .empty,
            version: 2,
            signature: .unsigned
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_valuesToReturn: [initialState : false,
                                                                              subsequentState : true],
                                         hasCompleteSubstate_valuesToReturn: [initialState : false,
                                                                              subsequentState : true],
                                         hasRelevantSignature_defaultValueToReturn: true)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertNil(sut.currentState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(subsequentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(sut.currentState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
    func test_didUpdateState_shouldFilterOutUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier",
                    name: "test-user-name"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .unsigned
        )
        
        let subsequentState = VersionedState(
            chatState: ChatState(
                currentUser: .populated(
                    identifier: "test-user-identifier",
                    name: "test-user-name"
                ),
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 2,
            signature: .unsigned
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_defaultValueToReturn: false,
                                         hasCompleteSubstate_defaultValueToReturn: true,
                                         hasRelevantSignature_defaultValueToReturn: true)
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.currentState, initialState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(subsequentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = initialState
        
        XCTAssertEqual(sut.currentState, expectedState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
    func test_didUpdateState_shouldFilterOutUnsupportedSignatures() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let initialState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let subsequentState = VersionedState(
            chatState: .empty,
            auxiliaryState: .empty,
            version: 2,
            signature: .subscriptionStateUpdated
        )
        
        let stubStore = StubStore(state_toReturn: initialState, register_expectedCallCount: 1, unregister_expectedCallCount: 1)
        let stubFilter = StubStateFilter(hasModifiedSubstate_defaultValueToReturn: true,
                                         hasCompleteSubstate_defaultValueToReturn: true,
                                         hasRelevantSignature_valuesToReturn: [.initialState : true,
                                                                                .subscriptionStateUpdated : false])
        let stubDelegate = StubBufferDelegate(didUpdateState_expectedCallCount: 0)
        
        let dependencies = DependenciesDoubles(store: stubStore)
        
        let sut = ConcreteBuffer(filter: stubFilter, dependencies: dependencies)
        sut.delegate = stubDelegate
        
        XCTAssertEqual(sut.currentState, initialState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        stubStore.report(subsequentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = initialState
        
        XCTAssertEqual(sut.currentState, expectedState)
        XCTAssertEqual(stubDelegate.didUpdateState_actualCallCount, 0)
        XCTAssertNil(stubDelegate.didUpdateState_stateLastReceived)
    }
    
}
