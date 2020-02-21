import XCTest
@testable import PusherChatkit

class RoomTests: XCTestCase {
    
    // MARK: - Properties
    
    var firstTestUser: User!
    var secondTestUser: User!
    var thirdTestUser: User!
    
    var now: Date!
    
    var firstTestCustomData: CustomData!
    var secondTestCustomData: CustomData!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        self.now = Date()
        
        self.firstTestUser = User(identifier: "firstUserIdentifier",
                                  name: "firstUser",
                                  avatar: nil,
                                  presenceState: .unknown,
                                  customData: nil,
                                  createdAt: Date.distantPast,
                                  updatedAt: self.now)
        
        self.secondTestUser = User(identifier: "secondUserIdentifier",
                                   name: "secondUser",
                                   avatar: nil,
                                   presenceState: .unknown,
                                   customData: nil,
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now)
        
        self.thirdTestUser = User(identifier: "thirdUserIdentifier",
                                  name: "thirdUser",
                                  avatar: nil,
                                  presenceState: .unknown,
                                  customData: nil,
                                  createdAt: Date.distantPast,
                                  updatedAt: self.now)
        
        self.firstTestCustomData = ["firstKey" : "firstValue"]
        self.secondTestCustomData = ["secondKey" : "secondValue"]
    }
    
    // MARK: - Tests
    
    func testShouldCreateRoomWithCorrectValues() {
        let room = Room(identifier: "testIdentifier",
                        name: "testName",
                        isPrivate: true,
                        unreadCount: 5,
                        lastMessageAt: self.now,
                        customData: self.firstTestCustomData,
                        createdAt: Date.distantPast,
                        updatedAt: self.now)
        
        XCTAssertEqual(room.identifier, "testIdentifier")
        XCTAssertEqual(room.name, "testName")
        XCTAssertTrue(room.isPrivate)
        XCTAssertEqual(room.unreadCount, 5)
        XCTAssertEqual(room.lastMessageAt, self.now)
        XCTAssertNotNil(room.customData)
        XCTAssertEqual(room.customData as? [String : String], self.firstTestCustomData as? [String : String])
        XCTAssertEqual(room.createdAt, Date.distantPast)
        XCTAssertEqual(room.updatedAt, self.now)
    }
    
    func testRoomShouldHaveTheSameHashForTheSameIdentifiers() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: Date.distantPast,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantPast)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "anotherName",
                              isPrivate: false,
                              unreadCount: 25,
                              lastMessageAt: self.now,
                              customData: self.secondTestCustomData,
                              createdAt: self.now,
                              updatedAt: self.now)
        
        XCTAssertEqual(firstRoom.hashValue, secondRoom.hashValue)
    }
    
    func testRoomShouldOnlyUseIdentifierToGenerateHash() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "anotherIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom.hashValue, secondRoom.hashValue)
    }
    
    func testShouldCompareTwoRoomsAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenIdentifierValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "anotherIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenNameValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "anotherName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenIsPrivateValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: false,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenUnreadCountValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 25,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenLastMessageAtValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: Date.distantPast,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: Date.distantFuture,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldCompareTwoRoomsAsEqualWhenCustomDataValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.secondTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now)
        
        XCTAssertEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenCreatedAtValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: self.now,
                              updatedAt: self.now)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenUpdatedAtValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessageAt: self.now,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessageAt: self.now,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantPast)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
}
