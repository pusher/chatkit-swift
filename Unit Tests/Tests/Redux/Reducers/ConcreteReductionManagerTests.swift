import XCTest
import TestUtilities
@testable import PusherChatkit

class ConcreteReductionManagerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withReceivedInitialStateAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: .empty
        )
        
        let userSubscriptionInitialStateReducer = StubReducer<ChatState>(reducer_expectedState: expectedState, reducer_expectedCallCount: 1)
        let userSubscriptionRemovedFromRoomReducer = DummyReducer<ChatState>()
        
        let sut = ConcreteReductionManager(userSubscriptionInitialStateReducer: userSubscriptionInitialStateReducer.reducer,
                                           userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reducer)
        
        let currentState: ChatState = .empty
        
        let action = Action.receivedInitialState(
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
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.reduce(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reducer_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reducer_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reducer_stateLastReceived, currentState)
    }
    
    func test_reduce_withReceivedRemovedFromRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    RoomState(
                        identifier: "first-room",
                        name: "First"
                    )
                ]
            )
        )
        
        let userSubscriptionInitialStateReducer = DummyReducer<ChatState>()
        let userSubscriptionRemovedFromRoomReducer = StubReducer<ChatState>(reducer_expectedState: expectedState, reducer_expectedCallCount: 1)
        
        let sut = ConcreteReductionManager(userSubscriptionInitialStateReducer: userSubscriptionInitialStateReducer.reducer,
                                           userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reducer)
        
        let currentState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    RoomState(
                        identifier: "first-room",
                        name: "First"
                    ),
                    RoomState(
                        identifier: "second-room",
                        name: "Second"
                    )
                ]
            )
        )
        
        let action = Action.receivedRemovedFromRoom(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "second-room"
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.reduce(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reducer_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reducer_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reducer_stateLastReceived, currentState)
    }
    
}
