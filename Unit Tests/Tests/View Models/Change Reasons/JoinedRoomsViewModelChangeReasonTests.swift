import XCTest
@testable import PusherChatkit

class JoinedRoomsViewModelChangeReasonTests: XCTestCase {
    
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
    let modifiedSecondRoom = Room(identifier: "second-room-identifier",
                                  name: nil,
                                  isPrivate: false,
                                  unreadCount: 20,
                                  lastMessageAt: nil,
                                  customData: nil,
                                  createdAt: .distantPast,
                                  updatedAt: .distantPast)
    
    let firstPosition = 0
    let secondPosition = 1
    
    // MARK: - Tests
    
    func test_init_withoutChangeReason_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = nil
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = nil
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withAddedToRoomChangeReasonAndCurrentRoomsContainingRoom_shouldReturnItemInsertedWithCorrectPosition() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .addedToRoom(room: self.secondRoom)
        let currentRooms: [Room] = [
            self.firstRoom,
            self.secondRoom
        ]
        let previousRooms: [Room]? = nil
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemInserted(position: 1)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withAddedToRoomChangeReasonAndCurrentRoomsNotContainingRoom_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .addedToRoom(room: self.secondRoom)
        let currentRooms: [Room] = [
            self.firstRoom
        ]
        let previousRooms: [Room]? = nil
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withRemovedFromRoomChangeReasonAndPreviousRoomsContainingRoom_shouldReturnItemRemovedWithCorrectPositionAndPreviousValue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .removedFromRoom(room: self.secondRoom)
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: 1, previousValue: self.secondRoom)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRemovedFromRoomChangeReasonAndPreviousRoomsNotContainingRoom_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .removedFromRoom(room: self.secondRoom)
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = [
            self.firstRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withRemovedFromRoomChangeReasonAndNilPreviousRooms_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .removedFromRoom(room: self.secondRoom)
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = nil
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withRoomDeletedChangeReasonAndPreviousRoomsContainingRoom_shouldReturnItemRemovedWithCorrectPositionAndPreviousValue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .roomDeleted(room: self.secondRoom)
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: 1, previousValue: self.secondRoom)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRoomDeletedChangeReasonAndPreviousRoomsNotContainingRoom_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .roomDeleted(room: self.secondRoom)
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = [
            self.firstRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withRoomDeletedChangeReasonAndNilPreviousRooms_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .roomDeleted(room: self.secondRoom)
        let currentRooms: [Room] = []
        let previousRooms: [Room]? = nil
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withRoomUpdatedChangeReasonAndCurrentRoomsContainingUpdatedRoomAndPreviousRoomsContainingPreviousValueAtTheSameIndex_shouldReturnItemChangedWithCorrectPositionAndPreviousValue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .roomUpdated(updatedRoom: self.modifiedSecondRoom, previousValue: self.secondRoom)
        let currentRooms: [Room] = [
            self.firstRoom,
            self.modifiedSecondRoom
        ]
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: 1, previousValue: self.secondRoom)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRoomUpdatedChangeReasonAndCurrentRoomsContainingUpdatedRoomAndPreviousRoomsContainingPreviousValueAtDifferentIndex_shouldReturnItemMovedWithCorrectFromPositionAndToPosition() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .roomUpdated(updatedRoom: self.modifiedSecondRoom, previousValue: self.secondRoom)
        let currentRooms: [Room] = [
            self.modifiedSecondRoom,
            self.firstRoom
        ]
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: 1, toPosition: 0)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withRoomUpdatedChangeReasonAndCurrentRoomsNotContainingUpdatedRoomAndPreviousRoomsContainingPreviousValue_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .roomUpdated(updatedRoom: self.modifiedSecondRoom, previousValue: self.secondRoom)
        let currentRooms: [Room] = [
            self.firstRoom
        ]
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_init_withReadStateUpdatedChangeReasonAndCurrentRoomsContainingUpdatedRoomAndPreviousRoomsContainingPreviousValueAtTheSameIndex_shouldReturnItemChangedWithCorrectPositionAndPreviousValue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .readStateUpdated(updatedRoom: self.modifiedSecondRoom, previousValue: self.secondRoom)
        let currentRooms: [Room] = [
            self.firstRoom,
            self.modifiedSecondRoom
        ]
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: 1, previousValue: self.secondRoom)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withReadStateUpdatedChangeReasonAndCurrentRoomsContainingUpdatedRoomAndPreviousRoomsContainingPreviousValueAtDifferentIndex_shouldReturnItemMovedWithCorrectFromPositionAndToPosition() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .readStateUpdated(updatedRoom: self.modifiedSecondRoom, previousValue: self.secondRoom)
        let currentRooms: [Room] = [
            self.modifiedSecondRoom,
            self.firstRoom
        ]
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        let expectedValue: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: 1, toPosition: 0)
        
        XCTAssertEqual(result, expectedValue)
    }
    
    func test_init_withReadStateUpdatedChangeReasonAndCurrentRoomsNotContainingUpdatedRoomAndPreviousRoomsContainingPreviousValue_shouldReturnNil() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let repositoryChangeReason: JoinedRoomsRepository.ChangeReason? = .readStateUpdated(updatedRoom: self.modifiedSecondRoom, previousValue: self.secondRoom)
        let currentRooms: [Room] = [
            self.firstRoom
        ]
        let previousRooms: [Room]? = [
            self.firstRoom,
            self.secondRoom
        ]
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = JoinedRoomsViewModel.ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: currentRooms, previousRooms: previousRooms)
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNil(result)
    }
    
    func test_equality_withDifferentChangeReasons_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let itemInsertedChangeReason: JoinedRoomsViewModel.ChangeReason = .itemInserted(position: self.firstPosition)
        let itemMovedChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.firstPosition, toPosition: self.firstPosition)
        let itemChangedChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.firstPosition, previousValue: self.firstRoom)
        let itemRemovedChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.firstPosition, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let itemInsertedItemMovedResult = itemInsertedChangeReason == itemMovedChangeReason
        let itemInsertedItemChangedResult = itemInsertedChangeReason == itemChangedChangeReason
        let itemInsertedItemRemovedResult = itemInsertedChangeReason == itemRemovedChangeReason
        
        let itemMovedItemChangedResult = itemMovedChangeReason == itemChangedChangeReason
        let itemMovedItemRemovedResult = itemMovedChangeReason == itemRemovedChangeReason
        
        let itemChangedItemRemovedResult = itemChangedChangeReason == itemRemovedChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(itemInsertedItemMovedResult)
        XCTAssertFalse(itemInsertedItemChangedResult)
        XCTAssertFalse(itemInsertedItemRemovedResult)
        
        XCTAssertFalse(itemMovedItemChangedResult)
        XCTAssertFalse(itemMovedItemRemovedResult)
        
        XCTAssertFalse(itemChangedItemRemovedResult)
    }
    
    func test_equality_withItemInsertedAndItemInsertedHavingEqualPositions_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemInserted(position: self.firstPosition)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemInserted(position: self.firstPosition)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withItemInsertedAndItemInsertedHavingDifferentPositions_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemInserted(position: self.firstPosition)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemInserted(position: self.secondPosition)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withItemMovedAndItemMovedHavingEqualFromPositionsAndToPositions_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.firstPosition, toPosition: self.firstPosition)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.firstPosition, toPosition: self.firstPosition)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withItemMovedAndItemMovedHavingDifferentFromPositionsAndEqualToPositions_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.firstPosition, toPosition: self.firstPosition)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.secondPosition, toPosition: self.firstPosition)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withItemMovedAndItemMovedHavingEqualFromPositionsAndDifferentToPositions_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.firstPosition, toPosition: self.firstPosition)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemMoved(fromPosition: self.firstPosition, toPosition: self.secondPosition)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withItemChangedAndItemChangedHavingEqualFromPositionsAndPreviousValues_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.firstPosition, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.firstPosition, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withItemChangedAndItemChangedHavingDifferentFromPositionsAndEqualPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.firstPosition, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.secondPosition, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withItemChangedAndItemChangedHavingEqualFromPositionsAndDifferentPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.firstPosition, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemChanged(position: self.firstPosition, previousValue: self.secondRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withItemRemovedAndItemRemovedHavingEqualFromPositionsAndPreviousValues_shouldReturnTrue() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.firstPosition, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.firstPosition, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertTrue(result)
    }
    
    func test_equality_withItemRemovedAndItemRemovedHavingDifferentFromPositionsAndEqualPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.firstPosition, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.secondPosition, previousValue: self.firstRoom)
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let result = firstChangeReason == secondChangeReason
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertFalse(result)
    }
    
    func test_equality_withItemRemovedAndItemRemovedHavingEqualFromPositionsAndDifferentPreviousValues_shouldReturnFalse() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.firstPosition, previousValue: self.firstRoom)
        let secondChangeReason: JoinedRoomsViewModel.ChangeReason = .itemRemoved(position: self.firstPosition, previousValue: self.secondRoom)
        
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
