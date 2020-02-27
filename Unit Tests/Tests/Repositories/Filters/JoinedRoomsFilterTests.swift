import XCTest
@testable import PusherChatkit

class JoinedRoomsFilterTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_hasModifiedSubstateWithEqualStates_returnsFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let oldState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "test-identifier",
                            name: "test-name",
                            isPrivate: true,
                            pushNotificationTitle: "test-push-notification-title",
                            customData: [
                                "test-key" : "test-value"
                            ],
                            lastMessageAt: .distantPast,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantFuture
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let newState = oldState
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasModifiedSubstate(oldState: oldState, newState: newState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_hasModifiedSubstateWithModifiedSubstateThatIsNotMonitoredByTheFilter_returnsFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let oldState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "test-identifier",
                            name: "test-name",
                            isPrivate: true,
                            pushNotificationTitle: "test-push-notification-title",
                            customData: [
                                "test-key" : "test-value"
                            ],
                            lastMessageAt: .distantPast,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantFuture
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let newState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "test-identifier",
                            name: "test-name",
                            isPrivate: true,
                            pushNotificationTitle: "test-push-notification-title",
                            customData: [
                                "test-key" : "test-value"
                            ],
                            lastMessageAt: .distantPast,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantFuture
                        )
                    ]
                ),
                users: UserListState(
                    elements: [
                        .partial(identifier: "test-user")
                    ]
                )
            ),
            auxiliaryState: .empty,
            version: 2,
            signature: .addedToRoom
        )
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasModifiedSubstate(oldState: oldState, newState: newState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_hasModifiedSubstateWithModifiedSubstateThatIsMonitoredByTheFilter_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let oldState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "test-identifier",
                            name: "test-name",
                            isPrivate: true,
                            pushNotificationTitle: "test-push-notification-title",
                            customData: [
                                "test-key" : "test-value"
                            ],
                            lastMessageAt: .distantPast,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantFuture
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let newState = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: .empty,
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 2,
            signature: .roomDeleted
        )
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasModifiedSubstate(oldState: oldState, newState: newState)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasCompleteSubstateWithCompleteState_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "test-identifier",
                            name: "test-name",
                            isPrivate: true,
                            pushNotificationTitle: "test-push-notification-title",
                            customData: [
                                "test-key" : "test-value"
                            ],
                            lastMessageAt: .distantPast,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantFuture
                        )
                    ]
                ),
                users: .empty
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasCompleteSubstate(state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasCompleteSubstateWithIncompleteSubstateThatIsMonitoredByTheFilter_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let state = VersionedState(
            chatState: ChatState(
                currentUser: .empty,
                joinedRooms: RoomListState(
                    elements: [
                        RoomState(
                            identifier: "test-identifier",
                            name: "test-name",
                            isPrivate: true,
                            pushNotificationTitle: "test-push-notification-title",
                            customData: [
                                "test-key" : "test-value"
                            ],
                            lastMessageAt: .distantPast,
                            readSummary: ReadSummaryState(
                                unreadCount: 10
                            ),
                            createdAt: .distantPast,
                            updatedAt: .distantFuture
                        )
                    ]
                ),
                users: UserListState(
                    elements: [
                        .partial(identifier: "user-identifier")
                    ]
                )
            ),
            auxiliaryState: .empty,
            version: 1,
            signature: .initialState
        )
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasCompleteSubstate(state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithInitialStateSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .initialState
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithAddedToRoomSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .addedToRoom
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithRemovedFromRoomSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .removedFromRoom
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithRoomUpdatedSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .roomUpdated
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithRoomDeletedSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .roomDeleted
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithReadStateUpdatedSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .readStateUpdated
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasSupportedSignatureWithUnsupportewdSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .unsigned
        
        let sut = JoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasSupportedSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
}
