import XCTest
import TestUtilities
@testable import PusherChatkit

class UserReducerTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_reduce_withgInitialStateAction_returnsModifiedState() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let inputState: UserState = .empty
        
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
                readStates: [],
                memberships: []
            )
        )
        
        let dependencies = DependenciesDoubles()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let outputState = Reducer.Model.User.reduce(action: action, state: inputState, dependencies: dependencies)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedState: UserState = .populated(
            identifier: "alice",
            name: "Alice A"
        )
        
        XCTAssertEqual(outputState, expectedState)
    }
    
}
