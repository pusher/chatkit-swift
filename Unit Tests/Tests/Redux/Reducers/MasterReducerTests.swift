import XCTest
import TestUtilities
@testable import PusherChatkit

class MasterReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withInitialStateAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = MasterState(
            currentUser: TestState.user,
            joinedRooms: .empty,
            users: TestState.userList
        )
        
        let userSubscriptionInitialStateReducer = StubReducer<Reducer.UserSubscription.InitialState>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                     reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(initialStateUserSubscriptionReducer: userSubscriptionInitialStateReducer.reduce)
        
        let inputState: MasterState = .empty
        
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
    
    func test_reduce_withRemovedFromRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let userSubscriptionRemovedFromRoomReducer = StubReducer<Reducer.UserSubscription.RemovedFromRoom>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                           reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userSubscriptionRemovedFromRoomReducer: userSubscriptionRemovedFromRoomReducer.reduce)
        
        let inputState = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
                        identifier: "second-room",
                        name: "Second",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let action = RemovedFromRoomAction(
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
    
    func test_reduce_withRoomUpdatedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
                        identifier: "second-room",
                        name: "Second Room",
                        isPrivate: true,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let userSubscriptionRoomUpdatedReducer = StubReducer<Reducer.UserSubscription.RoomUpdated>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                   reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userSubscriptionRoomUpdatedReducer: userSubscriptionRoomUpdatedReducer.reduce)
        
        let inputState = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
                        identifier: "second-room",
                        name: "Second",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let action = RoomUpdatedAction(
            event: Wire.Event.RoomUpdated(
                room: Wire.Room(
                    identifier: "second-room",
                    name: "Second Room",
                    createdById: TestState.userIdentifier,
                    isPrivate: true,
                    pushNotificationTitleOverride: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast,
                    deletedAt: .distantPast
                )
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
        XCTAssertEqual(userSubscriptionRoomUpdatedReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRoomUpdatedReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRoomUpdatedReducer.reduce_stateLastReceived, inputState)
    }
    
    func test_reduce_withRoomDeletedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let userSubscriptionRoomDeletedReducer = StubReducer<Reducer.UserSubscription.RoomDeleted>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                   reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userSubscriptionRoomDeletedReducer: userSubscriptionRoomDeletedReducer.reduce)
        
        let inputState = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    ),
                    "second-room" : RoomState(
                        identifier: "second-room",
                        name: "Second",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let action = RoomDeletedAction(
            event: Wire.Event.RoomDeleted(
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
        XCTAssertEqual(userSubscriptionRoomDeletedReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRoomDeletedReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRoomDeletedReducer.reduce_stateLastReceived, inputState)
    }
    
    func test_reduce_withReadStateUpdatedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 20
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let userSubscriptionReadStateUpdatedReducer = StubReducer<Reducer.UserSubscription.ReadStateUpdated>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                             reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userSubscriptionReadStateUpdatedReducer: userSubscriptionReadStateUpdatedReducer.reduce)
        
        let inputState = MasterState(
            currentUser: TestState.user,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 10
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: TestState.userList
        )
        
        let action = ReadStateUpdatedAction(
            event: Wire.Event.ReadStateUpdated(
                readState: Wire.ReadState(
                    roomIdentifier: "first-room",
                    unreadCount: 20,
                    cursor: nil)
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
        XCTAssertEqual(userSubscriptionReadStateUpdatedReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionReadStateUpdatedReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionReadStateUpdatedReducer.reduce_stateLastReceived, inputState)
    }
    
    func test_reduce_withUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        let inputState = MasterState(
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
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
            currentUser: .empty,
            joinedRooms: RoomListState(
                rooms: [
                    "first-room" : RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: .empty,
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
