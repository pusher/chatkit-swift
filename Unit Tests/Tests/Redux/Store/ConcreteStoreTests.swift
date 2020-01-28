import XCTest
@testable import TestUtilities
@testable import PusherChatkit

class ConcreteStoreTests: XCTestCase {
    
    func test_action_actionThatDoesChangeInternalState_delegateTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_callCount, 0)
        
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
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_callCount, 1)
        XCTAssertEqual(stubStoreDelegate.didUpdateState_stateLastReceived, expectedState)
    }
    
    func test_action_actionThatDoesNotChangeInternalState_delegateNotTriggered() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 2)
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)
        
        let initialStateAction = Action.subscriptionEvent(
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
        
        sut.action(initialStateAction)
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_callCount, 1)
        
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
        
        let expectedState = State(
            currentUser: Internal.User(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: []
        )
        
        XCTAssertEqual(stubStoreDelegate.didUpdateState_stateLastReceived, expectedState)
        XCTAssertEqual(stubStoreDelegate.didUpdateState_callCount, 1) // <--- Call count has NOT increased!
    }
}
