import XCTest
import TestUtilities
@testable import PusherChatkit

class RoomsReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withCurrentStateAndInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: RoomListState = .empty
        
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
                rooms: [
                    Wire.Room(
                        identifier: "first-room",
                        name: "First",
                        createdById: "user-id",
                        isPrivate: true,
                        pushNotificationTitleOverride: "title",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast,
                        deletedAt: nil),
                    Wire.Room(
                        identifier: "second-room",
                        name: "Second",
                        createdById: "user-id",
                        isPrivate: false,
                        pushNotificationTitleOverride: nil,
                        customData: [
                            "key" : "value"
                        ],
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast,
                        deletedAt: nil)
                ],
                readStates: [
                    Wire.ReadState(
                        roomIdentifier: "first-room",
                        unreadCount: 10,
                        cursor: nil
                    ),
                    Wire.ReadState(
                        roomIdentifier: "second-room",
                        unreadCount: 0,
                        cursor: nil
                    )
                ],
                memberships: []
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
            rooms: [
                "first-room" : RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: true,
                    pushNotificationTitle: "title",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 10
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: [
                        "key" : "value"
                    ],
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndInitialStateActionWithMissingReadState_returnsModifiedStateWithoutReadSummary() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: RoomListState = .empty
        
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
                rooms: [
                    Wire.Room(
                        identifier: "first-room",
                        name: "First",
                        createdById: "user-id",
                        isPrivate: true,
                        pushNotificationTitleOverride: "title",
                        customData: nil,
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast,
                        deletedAt: nil),
                    Wire.Room(
                        identifier: "second-room",
                        name: "Second",
                        createdById: "user-id",
                        isPrivate: false,
                        pushNotificationTitleOverride: nil,
                        customData: [
                            "key" : "value"
                        ],
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast,
                        deletedAt: nil)
                ],
                readStates: [
                    Wire.ReadState(
                        roomIdentifier: "first-room",
                        unreadCount: 10,
                        cursor: nil
                    )
                ],
                memberships: []
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
            rooms: [
                "first-room" : RoomState(
                    identifier: "first-room",
                    name: "First",
                    isPrivate: true,
                    pushNotificationTitle: "title",
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 10
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: [
                        "key" : "value"
                    ],
                    lastMessageAt: .distantPast,
                    readSummary: .empty,
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndRemovedFromRoomActionForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = RemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "second-room"
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndRemovedFromRoomActionForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = RemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "third-room"
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndRoomUpdatedActionForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
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
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second Room",
                    isPrivate: true,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndRoomUpdatedActionForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = RoomUpdatedAction(
            event: Wire.Event.RoomUpdated(
                room: Wire.Room(
                    identifier: "third-room",
                    name: "Third",
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
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndRoomDeletedActionForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = RoomDeletedAction(
            event: Wire.Event.RoomDeleted(
                roomIdentifier: "second-room"
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndRoomDeletedActionForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = RoomDeletedAction(
            event: Wire.Event.RoomDeleted(
                roomIdentifier: "third-room"
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndReadStateUpdatedActionForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = ReadStateUpdatedAction(
            event: Wire.Event.ReadStateUpdated(
                readState: Wire.ReadState(
                    roomIdentifier: "second-room",
                    unreadCount: 20,
                    cursor: nil)
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
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
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndReadStateUpdatedActionForNonExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        let action = ReadStateUpdatedAction(
            event: Wire.Event.ReadStateUpdated(
                readState: Wire.ReadState(
                    roomIdentifier: "third-room",
                    unreadCount: 20,
                    cursor: nil)
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
                    isPrivate: false,
                    pushNotificationTitle: nil,
                    customData: nil,
                    lastMessageAt: .distantPast,
                    readSummary: ReadSummaryState(
                        unreadCount: 0
                    ),
                    createdAt: .distantPast,
                    updatedAt: .distantPast
                )
            ]
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withCurrentStateAndUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
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
        )
        
        let action = DummyAction()
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.RoomList.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = RoomListState(
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
                ),
                "second-room" : RoomState(
                    identifier: "second-room",
                    name: "Second",
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
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
