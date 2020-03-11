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
    
}
