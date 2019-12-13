import XCTest
import CoreData
import PusherPlatform
@testable import PusherChatkit

class MessageTests: XCTestCase {
    
    // MARK: - Properties
    
    var persistenceController: PersistenceController!
    
    var testTextPart: MessagePart!
    var testLinkPart: MessagePart!
    
    var firstTestUser: User!
    var secondTestUser: User!
    var thirdTestUser: User!
    
    var now: Date!
    
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
            let firstMessageEntity = mainContext.create(MessageEntity.self)
            self.firstTestManagedObjectID = firstMessageEntity.objectID
            
            let secondMessageEntity = mainContext.create(MessageEntity.self)
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
        
        self.testTextPart = .inline("text/plain", "test")
        self.testLinkPart = .link("image/png", testURL)
    }
    
    // MARK: - Tests
    
    func testShouldCreateMessageWithCorrectValues() {
        let message = Message(identifier: "testIdentifier",
                              sender: self.firstTestUser,
                              parts: [self.testTextPart],
                              readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                              lastReadByUsers: [self.secondTestUser],
                              createdAt: Date.distantPast,
                              updatedAt: self.now,
                              deletedAt: Date.distantFuture,
                              objectID: self.firstTestManagedObjectID)
        
        XCTAssertEqual(message.identifier, "testIdentifier")
        XCTAssertEqual(message.sender, self.firstTestUser)
        XCTAssertEqual(message.createdAt, Date.distantPast)
        XCTAssertEqual(message.updatedAt, self.now)
        XCTAssertEqual(message.deletedAt, Date.distantFuture)
        XCTAssertEqual(message.objectID, self.firstTestManagedObjectID)
        XCTAssertEqual(message.parts.count, 1)
        XCTAssertTrue(message.parts.contains(self.testTextPart))
                
        XCTAssertEqual(message.readByUsers.count, 3)
        XCTAssertTrue(message.readByUsers.contains(self.firstTestUser))
        XCTAssertTrue(message.readByUsers.contains(self.secondTestUser))
        XCTAssertTrue(message.readByUsers.contains(self.thirdTestUser))
        
        XCTAssertEqual(message.lastReadByUsers.count, 1)
        XCTAssertTrue(message.lastReadByUsers.contains(self.secondTestUser))
    }
    
    func testMessageShouldHaveTheSameHashForTheSameIdentifiers() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: Date.distantPast,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                   sender: self.secondTestUser,
                                   parts: [self.testLinkPart],
                                   readByUsers: [self.secondTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: self.now,
                                   updatedAt: self.now,
                                   deletedAt: self.now,
                                   objectID: self.secondTestManagedObjectID)
        
        XCTAssertEqual(firstMessage.hashValue, secondMessage.hashValue)
    }
    
    func testMessageShouldOnlyUseIdentifierToGenerateHash() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "anotherIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage.hashValue, secondMessage.hashValue)
    }
    
    func testShouldCompareTwoMessagesAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenIdentifierValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "anotherIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenSenderValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.secondTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenPartsValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart, self.testLinkPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenReadByUsersValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenLastReadByUsersValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.firstTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenCreatedAtValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: self.now,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenUpdatedAtValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: Date.distantFuture,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenDeletedAtValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: self.now,
                                    objectID: self.firstTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
    func testShouldNotCompareTwoMessagesAsEqualWhenObjectIDValuesAreDifferent() {
        let firstMessage = Message(identifier: "testIdentifier",
                                   sender: self.firstTestUser,
                                   parts: [self.testTextPart],
                                   readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: Date.distantPast,
                                   updatedAt: self.now,
                                   deletedAt: Date.distantFuture,
                                   objectID: self.firstTestManagedObjectID)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture,
                                    objectID: self.secondTestManagedObjectID)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
}
