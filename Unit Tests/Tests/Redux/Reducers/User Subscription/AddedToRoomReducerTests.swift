import XCTest
import TestUtilities
@testable import PusherChatkit

class AddedToRoomReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withAddedToRoomAction_returnsStateFromDedicatedReducer() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState = ChatState(
            currentUser: .empty,
            joinedRooms: .empty,
            users: .empty
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
        
        let reducer_stateToReturn = RoomListState(
            rooms: [
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
        
        let expectedState = ChatState(
            currentUser: .empty,
            joinedRooms: reducer_stateToReturn,
            users: .empty
        )
        
        XCTAssertEqual(outputState, expectedState)
        XCTAssertEqual(stubReducer.reduce_actualCallCount, 1)
    }
    
}
