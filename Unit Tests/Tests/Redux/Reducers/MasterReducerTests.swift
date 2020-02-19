import XCTest
import TestUtilities
@testable import PusherChatkit

class MasterReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withInitialStateAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: .empty,
            users: .empty
        )
        
        let userSubscriptionInitialStateReducer = StubReducer<Reducer.UserSubscription.InitialState>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                     reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(initialStateUserSubscriptionReducer: userSubscriptionInitialStateReducer.reduce)
        
        let inputState: VersionedState = .initial
        
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 1,
            signature: .initialState
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionInitialStateReducer.reduce_stateLastReceived, .empty)
    }
    
    func test_reduce_withAddedToRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
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
                    ),
                    "third-room" : RoomState(
                        identifier: "third-room",
                        name: "Third",
                        isPrivate: false,
                        pushNotificationTitle: nil,
                        customData: nil,
                        lastMessageAt: .distantPast,
                        readSummary: ReadSummaryState(
                            unreadCount: 30
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let userSubscriptionAddedToRoomReducer = StubReducer<Reducer.UserSubscription.AddedToRoom>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                   reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userSubscriptionAddedToRoomReducer: userSubscriptionAddedToRoomReducer.reduce)
        
        let inputChatState = ChatState(
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
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
        )
        
        let action = AddedToRoomAction(
            event: Wire.Event.AddedToRoom(
                room: Wire.Room(
                    identifier: "third-room",
                    name: "Third",
                    createdById: "random-user",
                    isPrivate: false,
                    pushNotificationTitleOverride: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    createdAt: .distantPast,
                    updatedAt: .distantPast,
                    deletedAt: .distantPast),
                membership: Wire.Membership(
                    roomIdentifier: "third-room",
                    userIdentifiers: [
                        "random-user",
                        "alice"
                    ]
                ),
                readState: Wire.ReadState(
                    roomIdentifier: "third-room",
                    unreadCount: 30,
                    cursor: nil
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 2,
            signature: .addedToRoom
        )
        
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionAddedToRoomReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionAddedToRoomReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionAddedToRoomReducer.reduce_stateLastReceived, inputChatState)
    }
    
    func test_reduce_withRemovedFromRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
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
        
        let inputChatState = ChatState(
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
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 2,
            signature: .removedFromRoom
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRemovedFromRoomReducer.reduce_stateLastReceived, inputChatState)
    }
    
    func test_reduce_withRoomUpdatedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
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
        
        let inputChatState = ChatState(
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
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
        )
        
        let action = RoomUpdatedAction(
            event: Wire.Event.RoomUpdated(
                room: Wire.Room(
                    identifier: "second-room",
                    name: "Second Room",
                    createdById: "alice",
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 2,
            signature: .roomUpdated
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionRoomUpdatedReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRoomUpdatedReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRoomUpdatedReducer.reduce_stateLastReceived, inputChatState)
    }
    
    func test_reduce_withRoomDeletedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
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
        
        let inputChatState = ChatState(
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
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 2,
            signature: .roomDeleted
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionRoomDeletedReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionRoomDeletedReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionRoomDeletedReducer.reduce_stateLastReceived, inputChatState)
    }
    
    func test_reduce_withReadStateUpdatedAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
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
        
        let inputChatState = ChatState(
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
                            unreadCount: 10
                        ),
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            ),
            users: .empty
        )
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 2,
            signature: .readStateUpdated
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(userSubscriptionReadStateUpdatedReducer.reduce_actualCallCount, 1)
        XCTAssertEqual(userSubscriptionReadStateUpdatedReducer.reduce_actionLastReceived, action)
        XCTAssertEqual(userSubscriptionReadStateUpdatedReducer.reduce_stateLastReceived, inputChatState)
    }
    
    func test_reduce_withUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let dependencies = DependenciesDoubles()
        
        let inputChatState = ChatState(
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
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
        )
        
        let action = FakeAction()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Master.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = inputState
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withActionThatDoesModifyState_returnsStateWithCorrectVersionAndSignature() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputChatState = ChatState(
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
        
        let reducer_stateToReturn = inputChatState
        
        let userSubscriptionRoomUpdatedReducer = StubReducer<Reducer.UserSubscription.RoomUpdated>(reduce_stateToReturn: reducer_stateToReturn,
                                                                                                   reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userSubscriptionRoomUpdatedReducer: userSubscriptionRoomUpdatedReducer.reduce)
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
        )
        
        let action = RoomUpdatedAction(
            event: Wire.Event.RoomUpdated(
                room: Wire.Room(
                    identifier: "second-room",
                    name: "Second",
                    createdById: "alice",
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
        
        let expectedState = inputState
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withActionThatDoesNotModifyState_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let reducer_stateToReturn = ChatState(
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
        
        let inputChatState = ChatState(
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
        
        let inputState = VersionedState(
            chatState: inputChatState,
            version: 1,
            signature: .initialState
        )
        
        let action = RoomUpdatedAction(
            event: Wire.Event.RoomUpdated(
                room: Wire.Room(
                    identifier: "second-room",
                    name: "Second Room",
                    createdById: "alice",
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
        
        let expectedState = VersionedState(
            chatState: reducer_stateToReturn,
            version: 2,
            signature: .roomUpdated
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
