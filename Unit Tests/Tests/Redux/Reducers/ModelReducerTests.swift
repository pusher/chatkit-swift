import XCTest
@testable import PusherChatkit

class ModelReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_user_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: UserState? = nil
        
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
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.user(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: UserState = .populated(
            identifier: "alice",
            name: "Alice A"
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_roomList_withCurrentStateAndReceivedInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: [RoomState] = []
        
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
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.roomList(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = [
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
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_roomList_withCurrentStateAndReceivedRemovedFromRoomForExistingRoom_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = [
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
        
        let action = ReceivedRemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "second-room"
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.roomList(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = [
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
        
        XCTAssertEqual(outputState, expectedState)
    }
    
    func test_roomList_withCurrentStateAndReceivedRemovedFromRoomForNonExistingRoom_returnsUnmodifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = [
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
        
        let action = ReceivedRemovedFromRoomAction(
            event: Wire.Event.RemovedFromRoom(
                roomIdentifier: "third-room"
            )
        )
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.roomList(action: action, state: inputState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = [
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
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
