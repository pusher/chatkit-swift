import XCTest
@testable import PusherChatkit

class ModelReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_user_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState: UserState = .empty
        
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
                rooms: [
                    Wire.Room(
                        identifier: "first-room",
                        name: "First",
                        createdById: "user-id",
                        isPrivate: true,
                        pushNotificationTitleOverride: nil,
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
                        customData: nil,
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast,
                        deletedAt: nil)
                ],
                readStates: [],
                memberships: []
            )
        )
        
        let expectedState: UserState = .populated(
            identifier: "alice",
            name: "Alice A"
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Model.user(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_user_withCurrentStateAndUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState: UserState = .empty
        
        let action = Action.receivedRemovedFromRoom(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "room-identifier"
            )
        )
        
        let expectedState: UserState = .empty
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Model.user(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_roomList_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState: RoomListState = .empty
        
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
                rooms: [
                    Wire.Room(
                        identifier: "first-room",
                        name: "First",
                        createdById: "user-id",
                        isPrivate: true,
                        pushNotificationTitleOverride: nil,
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
                        customData: nil,
                        lastMessageAt: .distantPast,
                        createdAt: .distantPast,
                        updatedAt: .distantPast,
                        deletedAt: nil)
                ],
                readStates: [],
                memberships: []
            )
        )
        
        let expectedState = RoomListState(
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
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Model.roomList(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_roomList_withCurrentStateAndReceivedRemovedFromRoomForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState = RoomListState(
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
        
        let action = Action.receivedRemovedFromRoom(event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "second-room"
            )
        )
        
        let expectedState = RoomListState(
            rooms: [
                RoomState(
                    identifier: "first-room",
                    name: "First"
                )
            ]
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Model.roomList(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_roomList_withCurrentStateAndReceivedRemovedFromRoomForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState = RoomListState(
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
        
        let action = Action.receivedRemovedFromRoom(event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "third-room"
            )
        )
        
        let expectedState = RoomListState(
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
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Model.roomList(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_roomList_withCurrentStateAndUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState = RoomListState(
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
        
        let action = Action.fetching(userWithIdentifier: "user-id")
        
        let expectedState = RoomListState(
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
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.Model.roomList(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
}
