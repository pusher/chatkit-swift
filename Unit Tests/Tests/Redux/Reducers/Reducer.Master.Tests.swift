import XCTest
import TestUtilities
@testable import PusherChatkit

class Reducer_Master_Tests: XCTestCase {
    
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
        
        let userSubscriptionInitialStateReducer: StubReducer<Reducer.UserSubscription.InitialState.Typing> = .init(reduce_expectedState: expectedState, reduce_expectedCallCount: 1)
        
        let userSubscriptionRemovedFromRoomReducer: DummyReducer<Reducer.UserSubscription.RemovedFromRoom.Typing> = DummyReducer()
        
        let dependencies = DependenciesDoubles(
            reducer_userSubscription_initialState: userSubscriptionInitialStateReducer.reduce,
            reducer_userSubscription_removedFromRoom: userSubscriptionRemovedFromRoomReducer.reduce
        )
        
        let currentState: ChatState = .empty
        
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
        
        let result = Reducer.Master.reduce(action: action,
                                           state: currentState,
                                           dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_stateLastReceived, currentState)
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
        )
        
        let userSubscriptionInitialStateReducer: DummyReducer<Reducer.UserSubscription.InitialState.Typing> = DummyReducer()
        
        let userSubscriptionRemovedFromRoomReducer: StubReducer<Reducer.UserSubscription.RemovedFromRoom.Typing> =
            .init(reduce_expectedState: expectedState, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(
            reducer_userSubscription_initialState: userSubscriptionInitialStateReducer.reduce,
            reducer_userSubscription_removedFromRoom: userSubscriptionRemovedFromRoomReducer.reduce
        )
        
        let currentState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
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
        )
        
        let action = ReceivedRemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "second-room"
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Master.reduce(action: action,
                                           state: currentState,
                                           dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_stateLastReceived, currentState)
    }
    
    func test_reduce_withUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let expectedState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
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
        )
        
        let userSubscriptionInitialStateReducer: DummyReducer<Reducer.UserSubscription.InitialState.Typing> = DummyReducer()
        
        let userSubscriptionRemovedFromRoomReducer: DummyReducer<Reducer.UserSubscription.RemovedFromRoom.Typing> = DummyReducer()
        
        let dependencies = DependenciesDoubles(
            reducer_userSubscription_initialState: userSubscriptionInitialStateReducer.reduce,
            reducer_userSubscription_removedFromRoom: userSubscriptionRemovedFromRoomReducer.reduce
        )
        
        let currentState = ChatState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
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
        )
        
        let action = DummyAction()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Master.reduce(action: action,
                                           state: currentState,
                                           dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
}
