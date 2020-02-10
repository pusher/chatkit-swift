import XCTest
import TestUtilities
@testable import PusherChatkit

class UserSubscriptionReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_initialState_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
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
                readStates: [],
                memberships: []
            )
        )
        
        let expectedState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: RoomListState(
                rooms: [
                    RoomState(
                        identifier: "first-room",
                        name: "First",
                        isPrivate: true,
                        pushNotificationTitle: "title",
                        customData: nil,
                        lastMessageAt: .distantPast,
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
                        createdAt: .distantPast,
                        updatedAt: .distantPast
                    )
                ]
            )
        )
        
        let stubUsersReducer: StubReducer<Reducer.Model.User_forInitialState.Types> =
            .init(reduce_expectedState: expectedState.currentUser,
                  reduce_expectedCallCount: 1)
        
        let stubRoomsReducer: StubReducer<Reducer.Model.Rooms_forInitialState.Types> =
            .init(reduce_expectedState: expectedState.joinedRooms,
                  reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(reducer_model_user_forInitialState: stubUsersReducer.reduce,
                                               reducer_model_rooms_forInitialState: stubRoomsReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.InitialState.reduce(action: action,
                                                                  state: currentState,
                                                                  dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_removedFromRoom_withCurrentStateAndReceivedRemovedFromRoomForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
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
        
        let expectedState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
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
        
        let stubReducer: StubReducer<Reducer.Model.Rooms_forRemovedFromRoom.Types> =
            .init(reduce_expectedState: expectedState.joinedRooms,
                  reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(reducer_model_rooms_forRemovedFromRoom: stubReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.RemovedFromRoom.reduce(action: action,
                                                                     state: currentState,
                                                                     dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_removedFromRoom_withCurrentStateAndReceivedRemovedFromRoomForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
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
                roomIdentifier: "third-room"
            )
        )
        
        let expectedState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
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
        
        let stubReducer: StubReducer<Reducer.Model.Rooms_forRemovedFromRoom.Types> =
            .init(reduce_expectedState: expectedState.joinedRooms,
                  reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(reducer_model_rooms_forRemovedFromRoom: stubReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.RemovedFromRoom.reduce(action: action,
                                                                     state: currentState,
                                                                     dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
}
