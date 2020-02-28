import XCTest
import TestUtilities
@testable import PusherChatkit

class InitialStateReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: ChatState = .empty
        
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
        
        let userReducer_stateToReturn: UserState = .populated(
            identifier: "alice",
            name: "Alice A"
        )
        
        let roomListReducer_stateToReturn = RoomListState(
            elements: [
                RoomState(
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
                RoomState(
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
        
        let stubUsersReducer = StubReducer<Reducer.Model.User>(reduce_stateToReturn: userReducer_stateToReturn, reduce_expectedCallCount: 1)
        let stubRoomsReducer = StubReducer<Reducer.Model.RoomList>(reduce_stateToReturn: roomListReducer_stateToReturn, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userReducer: stubUsersReducer.reduce, roomListReducer: stubRoomsReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.InitialState.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = ChatState(
            currentUser: userReducer_stateToReturn,
            joinedRooms: roomListReducer_stateToReturn,
            users: UserListState(
                elements: [
                    userReducer_stateToReturn
                ]
            )
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_reduce_withInitialStateActionWithEmptyUserState_returnsEmptyListOfUsers() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: ChatState = .empty
        
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
        
        let userReducer_stateToReturn: UserState = .empty
        
        let roomListReducer_stateToReturn = RoomListState(
            elements: [
                RoomState(
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
                RoomState(
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
        
        let stubUsersReducer = StubReducer<Reducer.Model.User>(reduce_stateToReturn: userReducer_stateToReturn, reduce_expectedCallCount: 1)
        let stubRoomsReducer = StubReducer<Reducer.Model.RoomList>(reduce_stateToReturn: roomListReducer_stateToReturn, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(userReducer: stubUsersReducer.reduce, roomListReducer: stubRoomsReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.InitialState.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = ChatState(
            currentUser: userReducer_stateToReturn,
            joinedRooms: roomListReducer_stateToReturn,
            users: .empty
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}