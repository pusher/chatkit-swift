import TestUtilities
import XCTest
@testable import PusherChatkit

class ConcreteStoreTests: XCTestCase {
    
    // MARK: - Properties
    
    let testUser = UserState.populated(
        identifier: "alice",
        name: "Alice A"
    )
    
    // MARK: - Tests
    
    func test_init_stateStartsAsEmpty() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: nil)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(sut.state, MasterState.empty)
    }
    
    func test_dispatch_withActionThatDoesChangeInternalState_stateIsUpdated() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: .empty
        )
        
        let stubMasterReducer: StubReducer<Reducer.Master> =
            .init(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: nil)
        
        XCTAssertEqual(sut.state, MasterState.empty)
        
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
        
        let expectedState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: .empty
        )
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 1)
        
        let stubMasterReducer: StubReducer<Reducer.Master> =
            .init(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0)
        
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
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreDelegate.didUpdateState_stateLastReceived, expectedState)
    }
    
    func test_dispatch_withActionThatDoesNotChangeInternalState_stateIsUnchanged() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = MasterState.empty
        
        let stubMasterReducer: StubReducer<Reducer.Master> =
            .init(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: nil)
        
        XCTAssertEqual(sut.state, MasterState.empty)
        
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
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 2)
        
        let stubMasterReducer: StubReducer<Reducer.Master> =
            .init(reduce_stateToReturn: .empty, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0)
        
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
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0) // <--- Call count has NOT increased!
    }
    
    func test_dispatch_usesReductionManager_reduceTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: .empty
        )
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 1)
        
        let stubMasterReducer: StubReducer<Reducer.Master> =
            .init(reduce_stateToReturn: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(masterReducer: stubMasterReducer.reduce)
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0)
        
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
        XCTAssertEqual(stubMasterReducer.reduce_stateLastReceived, MasterState.empty)
    }
    
}
