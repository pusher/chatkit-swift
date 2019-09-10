import XCTest
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
    
    var firstTestMetadata: Metadata!
    var secondTestMetadata: Metadata!
    
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
                                      metadata: nil,
                                      createdAt: Date.distantPast,
                                      updatedAt: self.now,
                                      objectID: userEntityObjectID)
            
            self.secondTestUser = User(identifier: "secondUserIdentifier",
                                       name: "secondUser",
                                       avatar: nil,
                                       presenceState: .unknown,
                                       metadata: nil,
                                       createdAt: Date.distantPast,
                                       updatedAt: self.now,
                                       objectID: userEntityObjectID)
            
            self.thirdTestUser = User(identifier: "thirdUserIdentifier",
                                      name: "thirdUser",
                                      avatar: nil,
                                      presenceState: .unknown,
                                      metadata: nil,
                                      createdAt: Date.distantPast,
                                      updatedAt: self.now,
                                      objectID: userEntityObjectID)
        }
        
        let testURL = URL(fileURLWithPath: "/dev/null")
        
        let textPart = MessagePart.text("text/plain", "test")
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
        
        self.firstTestMetadata = ["firstKey" : "firstValue"]
        self.secondTestMetadata = ["secondKey" : "secondValue"]
    }
    
    // MARK: - Tests
    
    func testShouldCreateRoomWithCorrectValues() {
        let room = Room(identifier: "testIdentifier",
                        name: "testName",
                        isPrivate: true,
                        creator: self.firstTestUser,
                        members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                        typingMembers: [self.secondTestUser],
                        unreadCount: 5,
                        lastMessage: self.firstTestMessage,
                        metadata: self.firstTestMetadata,
                        createdAt: Date.distantPast,
                        updatedAt: self.now,
                        deletedAt: Date.distantFuture,
                        objectID: self.firstTestManagedObjectID)
        
        XCTAssertEqual(room.identifier, "testIdentifier")
        XCTAssertEqual(room.name, "testName")
        XCTAssertTrue(room.isPrivate)
        XCTAssertEqual(room.creator, self.firstTestUser)
        XCTAssertEqual(room.unreadCount, 5)
        XCTAssertEqual(room.lastMessage, self.firstTestMessage)
        XCTAssertNotNil(room.metadata)
        XCTAssertEqual(room.metadata as? [String : String], self.firstTestMetadata as? [String : String])
        XCTAssertEqual(room.createdAt, Date.distantPast)
        XCTAssertEqual(room.updatedAt, self.now)
        XCTAssertEqual(room.deletedAt, Date.distantFuture)
        XCTAssertEqual(room.objectID, self.firstTestManagedObjectID)
        
        guard let members = room.members else {
            XCTFail("Value of members property should not be nil.")
            return
        }
        
        XCTAssertEqual(members.count, 3)
        XCTAssertTrue(members.contains(self.firstTestUser))
        XCTAssertTrue(members.contains(self.secondTestUser))
        XCTAssertTrue(members.contains(self.thirdTestUser))
        
        guard let typingMembers = room.typingMembers else {
            XCTFail("Value of typingMembers property should not be nil.")
            return
        }
        
        XCTAssertEqual(typingMembers.count, 1)
        XCTAssertTrue(typingMembers.contains(self.secondTestUser))
    }
    
    func testRoomShouldHaveTheSameHashForTheSameIdentifiers() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantPast,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "anotherName",
                              isPrivate: false,
                              creator: self.secondTestUser,
                              members: [self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser, self.thirdTestUser],
                              unreadCount: 25,
                              lastMessage: self.secondTestMessage,
                              metadata: self.secondTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "anotherIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "anotherIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "anotherName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: false,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenCreatorValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.secondTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenMembersValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldNotCompareTwoRoomsAsEqualWhenTypingMembersValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser, self.thirdTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 25,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.secondTestMessage,
                              metadata: self.firstTestMetadata,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
    func testShouldCompareTwoRoomsAsEqualWhenMetadataValuesAreDifferent() {
        let firstRoom = Room(identifier: "testIdentifier",
                             name: "testName",
                             isPrivate: true,
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.secondTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
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
                             creator: self.firstTestUser,
                             members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                             typingMembers: [self.secondTestUser],
                             unreadCount: 5,
                             lastMessage: self.firstTestMessage,
                             metadata: self.firstTestMetadata,
                             createdAt: Date.distantPast,
                             updatedAt: self.now,
                             deletedAt: Date.distantFuture,
                             objectID: self.firstTestManagedObjectID)
        
        let secondRoom = Room(identifier: "testIdentifier",
                              name: "testName",
                              isPrivate: true,
                              creator: self.firstTestUser,
                              members: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              typingMembers: [self.secondTestUser],
                              unreadCount: 5,
                              lastMessage: self.firstTestMessage,
                              metadata: self.firstTestMetadata,
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.secondTestManagedObjectID)
        
        XCTAssertNotEqual(firstRoom, secondRoom)
    }
    
}
