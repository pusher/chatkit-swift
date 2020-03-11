import XCTest
@testable import PusherChatkit

class ConcreteJoinedRoomsRepositoryFilterTests: XCTestCase {
    
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
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
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
            signature: .subscriptionStateUpdated
        )
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
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
            signature: .roomDeleted(roomIdentifier: "test-identifier")
        )
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
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
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
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
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasCompleteSubstate(state)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithInitialStateSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .initialState
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithAddedToRoomSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .addedToRoom(roomIdentifier: "room-identifier")
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithRemovedFromRoomSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .removedFromRoom(roomIdentifier: "room-identifier")
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithRoomUpdatedSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .roomUpdated(roomIdentifier: "room-identifier")
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithRoomDeletedSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .roomDeleted(roomIdentifier: "room-identifier")
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithReadStateUpdatedSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .readStateUpdated(roomIdentifier: "room-identifier")
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_hasRelevantSignatureWithUnsupportewdSignature_returnsTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let signature:  VersionSignature = .unsigned
        
        let sut = ConcreteJoinedRoomsRepository.Filter()
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = sut.hasRelevantSignature(signature)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
}
