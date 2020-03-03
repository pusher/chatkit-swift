import XCTest
@testable import PusherChatkit

class VersionSignatureTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_hashValue_withDifferentSignatures_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let roomIdentifier = "room-identifier"
        
        let unsignedVersionSignature: VersionSignature = .unsigned
        let initialStateVersionSignature: VersionSignature = .initialState
        let addedToRoomVersionSignature: VersionSignature = .addedToRoom(roomIdentifier: roomIdentifier)
        let removedFromRoomVersionSignature: VersionSignature = .removedFromRoom(roomIdentifier: roomIdentifier)
        let roomUpdatedVersionSignature: VersionSignature = .roomUpdated(roomIdentifier: roomIdentifier)
        let roomDeletedVersionSignature: VersionSignature = .roomDeleted(roomIdentifier: roomIdentifier)
        let readStateUpdatedVersionSignature: VersionSignature = .readStateUpdated(roomIdentifier: roomIdentifier)
        let subscriptionStateUpdatedVersionSignature: VersionSignature = .subscriptionStateUpdated
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let unsignedHashValue = unsignedVersionSignature.hashValue
        let initialStateHashValue = initialStateVersionSignature.hashValue
        let addedToRoomHashValue = addedToRoomVersionSignature.hashValue
        let removedFromRoomHashValue = removedFromRoomVersionSignature.hashValue
        let roomUpdatedHashValue = roomUpdatedVersionSignature.hashValue
        let roomDeletedHashValue = roomDeletedVersionSignature.hashValue
        let readStateUpdatedHashValue = readStateUpdatedVersionSignature.hashValue
        let subscriptionStateUpdatedHashValue = subscriptionStateUpdatedVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(unsignedHashValue, initialStateHashValue)
        XCTAssertNotEqual(unsignedHashValue, addedToRoomHashValue)
        XCTAssertNotEqual(unsignedHashValue, removedFromRoomHashValue)
        XCTAssertNotEqual(unsignedHashValue, roomUpdatedHashValue)
        XCTAssertNotEqual(unsignedHashValue, roomDeletedHashValue)
        XCTAssertNotEqual(unsignedHashValue, readStateUpdatedHashValue)
        XCTAssertNotEqual(unsignedHashValue, subscriptionStateUpdatedHashValue)
        
        XCTAssertNotEqual(initialStateHashValue, addedToRoomHashValue)
        XCTAssertNotEqual(initialStateHashValue, removedFromRoomHashValue)
        XCTAssertNotEqual(initialStateHashValue, roomUpdatedHashValue)
        XCTAssertNotEqual(initialStateHashValue, roomDeletedHashValue)
        XCTAssertNotEqual(initialStateHashValue, readStateUpdatedHashValue)
        XCTAssertNotEqual(initialStateHashValue, subscriptionStateUpdatedHashValue)
        
        XCTAssertNotEqual(addedToRoomHashValue, removedFromRoomHashValue)
        XCTAssertNotEqual(addedToRoomHashValue, roomUpdatedHashValue)
        XCTAssertNotEqual(addedToRoomHashValue, roomDeletedHashValue)
        XCTAssertNotEqual(addedToRoomHashValue, readStateUpdatedHashValue)
        XCTAssertNotEqual(addedToRoomHashValue, subscriptionStateUpdatedHashValue)
        
        XCTAssertNotEqual(removedFromRoomHashValue, roomUpdatedHashValue)
        XCTAssertNotEqual(removedFromRoomHashValue, roomDeletedHashValue)
        XCTAssertNotEqual(removedFromRoomHashValue, readStateUpdatedHashValue)
        XCTAssertNotEqual(removedFromRoomHashValue, subscriptionStateUpdatedHashValue)
        
        XCTAssertNotEqual(roomUpdatedHashValue, roomDeletedHashValue)
        XCTAssertNotEqual(roomUpdatedHashValue, readStateUpdatedHashValue)
        XCTAssertNotEqual(roomUpdatedHashValue, subscriptionStateUpdatedHashValue)
        
        XCTAssertNotEqual(roomDeletedHashValue, readStateUpdatedHashValue)
        XCTAssertNotEqual(roomDeletedHashValue, subscriptionStateUpdatedHashValue)
        
        XCTAssertNotEqual(readStateUpdatedHashValue, subscriptionStateUpdatedHashValue)
    }
    
    func test_hashValue_withUnsignedAndUnsigned_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .unsigned
        let secondVersionSignature: VersionSignature = .unsigned
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withInitialStateAndInitialState_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .initialState
        let secondVersionSignature: VersionSignature = .initialState
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withAddedToRoomAndAddedToRoomHavingEqualRoomIdentifiers_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .addedToRoom(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .addedToRoom(roomIdentifier: "first-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withAddedToRoomAndAddedToRoomHavingDifferentRoomIdentifiers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .addedToRoom(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .addedToRoom(roomIdentifier: "second-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withRemovedFromRoomAndRemovedFromRoomHavingEqualRoomIdentifiers_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .removedFromRoom(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .removedFromRoom(roomIdentifier: "first-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withRemovedFromRoomAndRemovedFromRoomHavingDifferentRoomIdentifiers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .removedFromRoom(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .removedFromRoom(roomIdentifier: "second-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withRoomUpdatedAndRoomUpdatedHavingEqualRoomIdentifiers_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .roomUpdated(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .roomUpdated(roomIdentifier: "first-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withRoomUpdatedAndRoomUpdatedHavingDifferentRoomIdentifiers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .roomUpdated(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .roomUpdated(roomIdentifier: "second-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withRoomDeletedAndRoomDeletedHavingEqualRoomIdentifiers_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .roomDeleted(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .roomDeleted(roomIdentifier: "first-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withRoomDeletedAndRoomDeletedHavingDifferentRoomIdentifiers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .roomDeleted(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .roomDeleted(roomIdentifier: "second-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withReadStateUpdatedAndReadStateUpdatedHavingEqualRoomIdentifiers_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .readStateUpdated(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .readStateUpdated(roomIdentifier: "first-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withReadStateUpdatedAndReadStateUpdatedHavingDifferentRoomIdentifiers_shouldReturnDifferentValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .readStateUpdated(roomIdentifier: "first-room-identifier")
        let secondVersionSignature: VersionSignature = .readStateUpdated(roomIdentifier: "second-room-identifier")
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertNotEqual(firstHashValue, secondHashValue)
    }
    
    func test_hashValue_withSubscriptionStateUpdatedAndSubscriptionStateUpdated_shouldReturnEqualValues() {
        
        /******************/
        /*---- GIVEN -----*/
        /******************/
        
        let firstVersionSignature: VersionSignature = .subscriptionStateUpdated
        let secondVersionSignature: VersionSignature = .subscriptionStateUpdated
        
        /******************/
        /*----- WHEN -----*/
        /******************/
        
        let firstHashValue = firstVersionSignature.hashValue
        let secondHashValue = secondVersionSignature.hashValue
        
        /******************/
        /*----- THEN -----*/
        /******************/
        
        XCTAssertEqual(firstHashValue, secondHashValue)
    }
    
}
