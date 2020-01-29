import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class ConcreteStoreTests: XCTestCase {
    
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
        
        XCTAssertEqual(sut.state, State.empty)
    }
    
    func test_action_withActionThatDoesChangeInternalState_stateIsUpdated() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: nil)
        
        XCTAssertEqual(sut.state, State.empty)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = Action.subscriptionEvent(
            Wire.Event.EventType.initialState(
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
        )
        
        sut.action(action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = State(
            currentUser: Internal.User(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: []
        )
        
        XCTAssertEqual(sut.state, expectedState)
    }
    
    func test_action_withActionThatDoesChangeInternalState_delegateTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = Action.subscriptionEvent(
            Wire.Event.EventType.initialState(
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
        )
        
        sut.action(action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = State(
            currentUser: Internal.User(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: []
        )
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 1)
        XCTAssertEqual(stubStoreDelegate.didUpdateState_stateLastReceived, expectedState)
    }
    
    func test_action_withActionThatDoesNotChangeInternalState_stateIsUnchanged() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: nil)
        
        XCTAssertEqual(sut.state, State.empty)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = Action.subscriptionEvent(
            Wire.Event.EventType.removedFromRoom(
                event: Wire.Event.RemovedFromRoom(
                    roomIdentifier: "not-a-known-room"
                )
            )
        )
        
        sut.action(action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(sut.state, State.empty)
    }
    
    func test_action_withActionThatDoesNotChangeInternalState_delegateNotTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 2)
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let action = Action.subscriptionEvent(
            Wire.Event.EventType.removedFromRoom(
                event: Wire.Event.RemovedFromRoom(
                    roomIdentifier: "not-a-known-room"
                )
            )
        )
        
        sut.action(action)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_stateLastReceived, nil)
        XCTAssertEqual(stubStoreDelegate.didUpdateState_actualCallCount, 0) // <--- Call count has NOT increased!
    }
}
