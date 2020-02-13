import XCTest
import TestUtilities
@testable import PusherChatkit

class AddedToRoomReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withCurrentStateAndAddedToRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
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
            users: TestState.userList
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
                        TestState.userIdentifier
                    ]
                ),
                readState: Wire.ReadState(
                    roomIdentifier: "third-room",
                    unreadCount: 30,
                    cursor: nil
                )
            )
        )
        
        let reducer_stateToReturn = RoomListState(
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
        )
        
        let stubReducer = StubReducer<Reducer.Model.RoomList>(reduce_stateToReturn: reducer_stateToReturn, reduce_expectedCallCount: 1)
        
        let dependencies = DependenciesDoubles(roomListReducer: stubReducer.reduce)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.UserSubscription.AddedToRoom.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState = MasterState(
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
            users: TestState.userList
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(stubReducer.reduce_actualCallCount, 1)
    }
    
}
