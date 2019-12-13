import XCTest
import CoreData
import PusherPlatform
@testable import PusherChatkit

class RoomTests: XCTestCase {
    
    // MARK: - Properties
    
    var persistenceController: PersistenceController!
    
    var firstTestUser: User!
    var secondTestUser: User!
    var thirdTestUser: User!
    
    var firstTestMessage: Message!
    var secondTestMessage: Message!
    
    var now: Date!
    
    var firstTestCustomData: CustomData!
    var secondTestCustomData: CustomData!
    
    var firstTestManagedObjectID: NSManagedObjectID!
    var secondTestManagedObjectID: NSManagedObjectID!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        guard let url = Bundle.current.url(forResource: "Model", withExtension: "momd"), let model = NSManagedObjectModel(contentsOf: url) else {
            assertionFailure("Unable to locate test model.")
            return
        }
        
        let storeDescription = NSPersistentStoreDescription(inMemoryPersistentStoreDescription: ())
        storeDescription.shouldAddStoreAsynchronously = false
        
        guard let persistenceController = try? PersistenceController(model: model, storeDescriptions: [storeDescription]) else {
            assertionFailure("Failed to instantiate persistence controller.")
            return
        }
        
        self.persistenceController = persistenceController
        
        self.now = Date()
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let firstMessageEntity = mainContext.create(RoomEntity.self)
            self.firstTestManagedObjectID = firstMessageEntity.objectID
            
            let secondMessageEntity = mainContext.create(RoomEntity.self)
            self.secondTestManagedObjectID = secondMessageEntity.objectID
            
            let userEntity = mainContext.create(UserEntity.self)
            let userEntityObjectID = userEntity.objectID
            
            self.firstTestUser = User(identifier: "firstUserIdentifier",
                                      name: "firstUser",
                                      avatar: nil,
                                      presenceState: .unknown,
                                      customData: nil,
                                      createdAt: Date.distantPast,
                                      updatedAt: self.now,
                                      objectID: userEntityObjectID)
            
            self.secondTestUser = User(identifier: "secondUserIdentifier",
                                       name: "secondUser",
                                       avatar: nil,
                                       presenceState: .unknown,
                                       customData: nil,
                                       createdAt: Date.distantPast,
                                       updatedAt: self.now,
                                       objectID: userEntityObjectID)
            
            self.thirdTestUser = User(identifier: "thirdUserIdentifier",
                                      name: "thirdUser",
                                      avatar: nil,
                                      presenceState: .unknown,
                                      customData: nil,
                                      createdAt: Date.distantPast,
                                      updatedAt: self.now,
                                      objectID: userEntityObjectID)
        }
        
        let testURL = URL(fileURLWithPath: "/dev/null")
        
        let textPart = MessagePart.inline("text/plain", "test")
        let linkPart = MessagePart.link("image/png", testURL)
        
        let messageEntity = mainContext.create(MessageEntity.self)
        let messageEntityObjectID = messageEntity.objectID
        
        self.firstTestMessage = Message(identifier: "firstMessageIdentifier",
                                        sender: self.firstTestUser,
                                        parts: [textPart],
                                        readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                        lastReadByUsers: [self.secondTestUser],
                                        createdAt: Date.distantPast,
                                        updatedAt: self.now,
                                        deletedAt: Date.distantFuture,
                                        objectID: messageEntityObjectID)
        
        self.secondTestMessage = Message(identifier: "secondMessageIdentifier",
                                        sender: self.secondTestUser,
                                        parts: [linkPart],
                                        readByUsers: [self.secondTestUser, self.thirdTestUser],
                                        lastReadByUsers: [self.thirdTestUser],
                                        createdAt: self.now,
                                        updatedAt: self.now,
                                        deletedAt: self.now,
                                        objectID: messageEntityObjectID)
        
        self.firstTestCustomData = ["firstKey" : "firstValue"]
        self.secondTestCustomData = ["secondKey" : "secondValue"]
    }
    
    // MARK: - Tests
    
    func testShouldCreateRoomWithCorrectValues() {
        let room = Room(identifier: "testIdentifier",
                        name: "testName",
                        isPrivate: true,
                        unreadCount: 5,
                        lastMessage: self.firstTestMessage,
                        customData: self.firstTestCustomData,
                        createdAt: Date.distantPast,
                        updatedAt: self.now,
                        deletedAt: Date.distantFuture,
                        objectID: self.firstTestManagedObjectID)
        
        XCTAssertEqual(room.identifier, "testIdentifier")
        XCTAssertEqual(room.name, "testName")
        XCTAssertTrue(room.isPrivate)
        XCTAssertEqual(room.unreadCount, 5)
        XCTAssertEqual(room.lastMessage, self.firstTestMessage)
        XCTAssertNotNil(room.customData)
        XCTAssertEqual(room.customData as? [String : String], self.firstTestCustomData as? [String : String])
        XCTAssertEqual(room.createdAt, Date.distantPast)
        XCTAssertEqual(room.updatedAt, self.now)
        XCTAssertEqual(room.deletedAt, Date.distantFuture)
        XCTAssertEqual(room.objectID, self.firstTestManagedObjectID)
    }
    
    func testRoomShouldHaveTheSameHashForTheSameIdentifiers() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantPast,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "anotherName",
                              isPrivate: false,
                              unreadCount: 25,
                              lastMessage: self.secondTestMessage,
                              customData: self.secondTestCustomData,
                              createdAt: self.now,
                              updatedAt: self.now,
                              deletedAt: self.now,
                              objectID: self.secondTestManagedObjectID)
        
        XCTAssertEqual(firstRoom.hashValue, secondRoom.hashValue)
    }
    
    func testRoomShouldOnlyUseIdentifierToGenerateHash() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "anotherIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom.hashValue, secondRoom.hashValue)
    }
    
    func testShouldCompareTwoRoomsAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenIdentifierValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "anotherIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenNameValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "anotherName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenIsPrivateValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: false,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenUnreadCountValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 25,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenLastMessageValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.secondTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldCompareTwoRoomsAsEqualWhenCustomDataValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.secondTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenCreatedAtValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: self.now,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenUpdatedAtValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantPast,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenDeletedAtValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: self.now,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenObjectIDValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.secondTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
}
