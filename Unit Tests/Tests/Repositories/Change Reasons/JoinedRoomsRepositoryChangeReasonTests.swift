import XCTest
@testable import PusherChatkit

class JoinedRoomsRepositoryChangeReasonTests: XCTestCase {
    
    // MARK: - Properties
    
    let firstRoom = Room(identifier: "first-room-identifier",
                         name: nil,
                         isPrivate: false,
                         unreadCount: 10,
                         lastMessageAt: nil,
                         customData: nil,
                         createdAt: .distantPast,
                         updatedAt: .distantPast)
    
    let secondRoom = Room(identifier: "second-room-identifier",
                          name: nil,
                          isPrivate: false,
                          unreadCount: 10,
                          lastMessageAt: nil,
                          customData: nil,
                          createdAt: .distantPast,
                          updatedAt: .distantPast)
    
    // MARK: - Tests
    
    func test_equality_withDifferentChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let addedToRoomChangeReason: JoinedRoomsRepository.ChangeReason = .addedToRoom(room: self.firstRoom)
        let removedFromRoomChangeReason: JoinedRoomsRepository.ChangeReason = .removedFromRoom(room: self.firstRoom)
        let roomUpdatedChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        let readStateUpdatedChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        let roomDeletedChangeReason: JoinedRoomsRepository.ChangeReason = .roomDeleted(room: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let addedToRoomRemovedFromRoomResult = addedToRoomChangeReason == removedFromRoomChangeReason
        let addedToRoomRoomUpdatedResult = addedToRoomChangeReason == roomUpdatedChangeReason
        let addedToRoomReadStateUpdatedResult = addedToRoomChangeReason == readStateUpdatedChangeReason
        let addedToRoomRoomDeletedResult = addedToRoomChangeReason == roomDeletedChangeReason
        
        let removedFromRoomRoomUpdatedResult = removedFromRoomChangeReason == roomUpdatedChangeReason
        let removedFromRoomReadStateUpdatedResult = removedFromRoomChangeReason == readStateUpdatedChangeReason
        let removedFromRoomRoomDeletedResult = removedFromRoomChangeReason == roomDeletedChangeReason
        
        let roomUpdatedReadStateUpdatedResult = roomUpdatedChangeReason == readStateUpdatedChangeReason
        let roomUpdatedRoomDeletedResult = roomUpdatedChangeReason == roomDeletedChangeReason
        
        let readStateUpdatedRoomDeletedResult = readStateUpdatedChangeReason == roomDeletedChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(addedToRoomRemovedFromRoomResult)
        XCTAssertFalse(addedToRoomRoomUpdatedResult)
        XCTAssertFalse(addedToRoomReadStateUpdatedResult)
        XCTAssertFalse(addedToRoomRoomDeletedResult)
        
        XCTAssertFalse(removedFromRoomRoomUpdatedResult)
        XCTAssertFalse(removedFromRoomReadStateUpdatedResult)
        XCTAssertFalse(removedFromRoomRoomDeletedResult)
        
        XCTAssertFalse(roomUpdatedReadStateUpdatedResult)
        XCTAssertFalse(roomUpdatedRoomDeletedResult)
        
        XCTAssertFalse(readStateUpdatedRoomDeletedResult)
    }
    
    func test_equality_withAddedToRoomAndAddedToRoomHavingEqualRooms_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .addedToRoom(room: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .addedToRoom(room: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withAddedToRoomAndAddedToRoomHavingDifferentRooms_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .addedToRoom(room: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .addedToRoom(room: self.secondRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withRemovedFromRoomAndRemovedFromRoomHavingEqualRooms_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .removedFromRoom(room: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .removedFromRoom(room: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withRemovedFromRoomAndRemovedFromRoomHavingDifferentRooms_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .removedFromRoom(room: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .removedFromRoom(room: self.secondRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withRoomDeletedAndRoomDeletedHavingEqualRooms_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .roomDeleted(room: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .roomDeleted(room: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withRoomDeletedAndRoomDeletedHavingDifferentRooms_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .roomDeleted(room: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .roomDeleted(room: self.secondRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withRoomUpdatedAndRoomUpdatedHavingEqualUpdatedRoomsAndPreviousValues_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withRoomUpdatedAndRoomUpdatedHavingDifferentUpdatedRoomsAndEqualPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.firstRoom, previousValue: self.secondRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withRoomUpdatedAndRoomUpdatedHavingEqualUpdatedRoomsAndDifferentPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.secondRoom, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .roomUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withReadStateUpdatedAndReadStateUpdatedHavingEqualUpdatedRoomsAndPreviousValues_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withReadStateUpdatedAndReadStateUpdatedHavingDifferentUpdatedRoomsAndEqualPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.firstRoom, previousValue: self.secondRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withReadStateUpdatedAndReadStateUpdatedHavingEqualUpdatedRoomsAndDifferentPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.secondRoom, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsRepository.ChangeReason = .readStateUpdated(updatedRoom: self.firstRoom, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
}
