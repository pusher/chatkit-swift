import XCTest
@testable import PusherChatkit


class ConcreteStoreTests: XCTestCase {
    
    func test_stuff() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let stubStoreDelegate = StubStoreDelegate(didUpdateState_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles()
        
        let sut = ConcreteStore(dependencies: dependencies, delegate: stubStoreDelegate)

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
                        deletedAt: nil),
                    rooms: [],
                    readStates: [],
                    memberships: [])
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
    }
    
}
