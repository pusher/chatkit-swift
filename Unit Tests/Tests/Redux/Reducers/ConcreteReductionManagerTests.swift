import XCTest
import TestUtilities
@testable import PusherChatkit

class ConcreteReductionManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    let testUser = UserState.populated(
        identifier: "alice",
        name: "Alice A"
    )
    
    // MARK: - Tests
    
    func test_reduce_withReceivedInitialStateAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: []
        )
        
        let userSubscriptionInitialStateReducer = StubReducer<ReceivedInitialStateAction, ChatState>(reducer_stateToReturn: reducer_stateToReturn, reducer_expectedCallCount: 1)
        let userSubscriptionRemovedFromRoomReducer = DummyReducer<ReceivedRemovedFromRoomAction, ChatState>()
        
        let sut = ConcreteReductionManager(userSubscriptionInitialStateReducer: userSubscriptionInitialStateReducer.reducer,
                                           userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reducer)
        
        let inputState: ChatState = .empty
        
        let action = ReceivedInitialStateAction(
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
        
        let outputState = sut.reduce(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = reducer_stateToReturn
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reducer_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reducer_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reducer_stateLastReceived, inputState)
    }
    
    func test_reduce_withReceivedRemovedFromRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
            users: [],
            currentUser: nil,
            joinedRooms: [
                RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let userSubscriptionInitialStateReducer = DummyReducer<ReceivedInitialStateAction, ChatState>()
        let userSubscriptionRemovedFromRoomReducer = StubReducer<ReceivedRemovedFromRoomAction, ChatState>(reducer_stateToReturn: reducer_stateToReturn, reducer_expectedCallCount: 1)
        
        let sut = ConcreteReductionManager(userSubscriptionInitialStateReducer: userSubscriptionInitialStateReducer.reducer,
                                           userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reducer)
        
        let inputState = ChatState(
            users: [],
            currentUser: nil,
            joinedRooms: [
                RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                ),
                RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = ReceivedRemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "second-room"
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = sut.reduce(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = reducer_stateToReturn
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reducer_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reducer_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reducer_stateLastReceived, inputState)
    }
    
    func test_reduce_withUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let userSubscriptionInitialStateReducer = DummyReducer<ReceivedInitialStateAction, ChatState>()
        let userSubscriptionRemovedFromRoomReducer = DummyReducer<ReceivedRemovedFromRoomAction, ChatState>()
        
        let sut = ConcreteReductionManager(userSubscriptionInitialStateReducer: userSubscriptionInitialStateReducer.reducer,
                                           userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reducer)
        
        let inputState = ChatState(
            users: [],
            currentUser: nil,
            joinedRooms: [
                RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = DummyAction()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = sut.reduce(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = ChatState(
            users: [],
            currentUser: nil,
            joinedRooms: [
                RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: false,
                    pushNotificationTitle: "nil",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
