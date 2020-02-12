import XCTest
import TestUtilities
@testable import PusherChatkit

class MasterReducerTests: XCTestCase {
    
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
        
        let reducer_stateToReturn = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
            joinedRooms: .empty
        )
        
        let userSubscriptionInitialStateReducer = StubReducer<Reducer.UserSubscription.InitialState>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                     reduce_expectedCallCount: 1)
        let userSubscriptionRemovedFromRoomReducer: DummyReducer<Reducer.UserSubscription.RemovedFromRoom> = DummyReducer()
        
        let dependencies = DependenciesDoubles(initialStateUserSubscriptionReducer: userSubscriptionInitialStateReducer.reduce,
                                               userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reduce)
        
        let inputState: MasterState = .empty
        
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
        
        let outputState = Reducer.Master.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = reducer_stateToReturn
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_stateLastReceived, inputState)
    }
    
    func test_reduce_withReceivedRemovedFromRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = MasterState(
            users: [],
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
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
        
        let userSubscriptionInitialStateReducer: DummyReducer<Reducer.UserSubscription.InitialState> = DummyReducer()
        let userSubscriptionRemovedFromRoomReducer = StubReducer<Reducer.UserSubscription.RemovedFromRoom>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                           reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(initialStateUserSubscriptionReducer: userSubscriptionInitialStateReducer.reduce,
                                               userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reduce)
        
        let inputState = MasterState(
            users: [],
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: "nil",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
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
        
        let outputState = Reducer.Master.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = reducer_stateToReturn
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_stateLastReceived, inputState)
    }
    
    func test_reduce_withUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let userSubscriptionInitialStateReducer: DummyReducer<Reducer.UserSubscription.InitialState> = DummyReducer()
        let userSubscriptionRemovedFromRoomReducer: DummyReducer<Reducer.UserSubscription.RemovedFromRoom> = DummyReducer()
        
        let dependencies = DependenciesDoubles(initialStateUserSubscriptionReducer: userSubscriptionInitialStateReducer.reduce,
                                               userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reduce)
        
        let inputState = MasterState(
            users: [],
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
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
        
        let outputState = Reducer.Master.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: [],
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
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
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
