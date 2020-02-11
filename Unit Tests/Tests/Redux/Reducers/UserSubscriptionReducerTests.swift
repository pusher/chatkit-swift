import XCTest
import TestUtilities
@testable import PusherChatkit

class UserSubscriptionReducerTests: XCTestCase {
    
    // MARK: - Properties
    
    let testUser = UserState.populated(
        identifier: "alice",
        name: "Alice A"
    )
    
    // MARK: - Tests
    
    func test_initialState_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
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
        
        let userReducer_stateToReturn = self.testUser
        
        let roomsReducer_stateToReturn = [
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
        
        let stubUsersReducer: StubReducer<Reducer.Model.User_forInitialState> =
            .init(reduce_stateToReturn: userReducer_stateToReturn,
                  reduce_expectedCallCount: 1)
        
        let stubRoomsReducer: StubReducer<Reducer.Model.Rooms_forInitialState> =
            .init(reduce_stateToReturn: roomsReducer_stateToReturn,
                  reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(reducer_model_user_forInitialState: stubUsersReducer.reduce,
                                               reducer_model_rooms_forInitialState: stubRoomsReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.InitialState.reduce(action: action,
                                                                       state: inputState,
                                                                       dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: [userReducer_stateToReturn],
            currentUser: userReducer_stateToReturn,
            joinedRooms: roomsReducer_stateToReturn
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_removedFromRoom_withCurrentStateAndReceivedRemovedFromRoomForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
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
        
        let reducer_stateToReturn = [
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
        
        let stubReducer: StubReducer<Reducer.Model.Rooms_forRemovedFromRoom> =
            .init(reduce_stateToReturn: reducer_stateToReturn,
                  reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(reducer_model_rooms_forRemovedFromRoom: stubReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.RemovedFromRoom.reduce(action: action,
                                                                          state: inputState,
                                                                          dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
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
    
    func test_removedFromRoom_withCurrentStateAndReceivedRemovedFromRoomForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = MasterState(
            users: [self.testUser],
            currentUser: self.testUser,
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
                roomIdentifier: "third-room"
            )
        )
        
        let reducer_stateToReturn = [
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
        
        let stubReducer: StubReducer<Reducer.Model.Rooms_forRemovedFromRoom> =
            .init(reduce_stateToReturn: reducer_stateToReturn,
                  reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(reducer_model_rooms_forRemovedFromRoom: stubReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.RemovedFromRoom.reduce(action: action,
                                                                          state: inputState,
                                                                          dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = MasterState(
            users: inputState.users,
            currentUser: inputState.currentUser,
            joinedRooms: reducer_stateToReturn
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
