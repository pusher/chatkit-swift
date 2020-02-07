import XCTest
@testable import PusherChatkit

class UserSubscriptionReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_initialState_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState: ChatState = .empty
        
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
        
        let expectedState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: RoomListState(
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
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.initialState(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    func test_initialState_withCurrentStateAndUnsupportedAction_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let currentState: ChatState = .empty
        
        let action = Action.receivedRemovedFromRoom(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "room-identifier"
            )
        )
        
        let expectedState: ChatState = .empty
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.initialState(action: action, state: currentState)
        
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
                        name: "First"
                    ),
                    RoomState(
                        identifier: "second-room",
                        name: "Second"
                    )
                ]
            )
        )
        
        let action = Action.receivedRemovedFromRoom(event: Wire.Event.RemovedFromRoom(
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
                        name: "First"
                    )
                ]
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.removedFromRoom(action: action, state: currentState)
        
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
                        name: "First"
                    ),
                    RoomState(
                        identifier: "second-room",
                        name: "Second"
                    )
                ]
            )
        )
        
        let action = Action.receivedRemovedFromRoom(event: Wire.Event.RemovedFromRoom(
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
                        name: "First"
                    ),
                    RoomState(
                        identifier: "second-room",
                        name: "Second"
                    )
                ]
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.removedFromRoom(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
    // TODO: Implement
    
    func test_removedFromRoom_withCurrentStateAndUnsupportedAction_returnsUnmodifiedState() {
        
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
                        name: "First"
                    ),
                    RoomState(
                        identifier: "second-room",
                        name: "Second"
                    )
                ]
            )
        )
        
        let action = Action.fetching(userWithIdentifier: "user-id")
        
        let expectedState = ChatState(
            currentUser: .populated(
                identifier: "alice",
                name: "Alice A"
            ),
            joinedRooms: RoomListState(
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
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = Reducer.UserSubscription.removedFromRoom(action: action, state: currentState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(result, expectedState)
    }
    
}
