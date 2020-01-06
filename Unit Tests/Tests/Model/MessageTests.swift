import XCTest
@testable import PusherChatkit

class MessageTests: XCTestCase {
    
    // MARK: - Properties
    
    var testTextPart: MessagePart!
    var testLinkPart: MessagePart!
    
    var firstTestUser: User!
    var secondTestUser: User!
    var thirdTestUser: User!
    
    var now: Date!
    
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
                              deletedAt: Date.distantFuture)
        
        XCTAssertEqual(message.identifier, "testIdentifier")
        XCTAssertEqual(message.sender, self.firstTestUser)
        XCTAssertEqual(message.createdAt, Date.distantPast)
        XCTAssertEqual(message.updatedAt, self.now)
        XCTAssertEqual(message.deletedAt, Date.distantFuture)
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                   sender: self.secondTestUser,
                                   parts: [self.testLinkPart],
                                   readByUsers: [self.secondTestUser],
                                   lastReadByUsers: [self.secondTestUser],
                                   createdAt: self.now,
                                   updatedAt: self.now,
                                   deletedAt: self.now)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "anotherIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "anotherIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.secondTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart, self.testLinkPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.firstTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: self.now,
                                    updatedAt: self.now,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: Date.distantFuture,
                                    deletedAt: Date.distantFuture)
        
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
                                   deletedAt: Date.distantFuture)
        
        let secondMessage = Message(identifier: "testIdentifier",
                                    sender: self.firstTestUser,
                                    parts: [self.testTextPart],
                                    readByUsers: [self.firstTestUser, self.secondTestUser, self.thirdTestUser],
                                    lastReadByUsers: [self.secondTestUser],
                                    createdAt: Date.distantPast,
                                    updatedAt: self.now,
                                    deletedAt: self.now)
        
        XCTAssertNotEqual(firstMessage, secondMessage)
    }
    
}
