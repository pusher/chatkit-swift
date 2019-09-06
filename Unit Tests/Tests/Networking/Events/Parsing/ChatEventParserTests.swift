import XCTest
import PusherPlatform
@testable import PusherChatkit

class ChatEventParserTests: XCTestCase {
    
    // MARK: - Properties
    
    var persistenceController: PersistenceController!
    
    var metadataPayload: [String : String]!
    var event: Event!
    
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
        
        self.metadataPayload = ["testKey" : "testValue"]
        
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        self.event = event
    }
    
    // MARK: - Tests
    
    func testShouldNotHaveAnyLoggerByDefault() {
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        XCTAssertNil(eventParser.logger)
    }
    
    func testShouldInstantiateWithCorrectValues() {
        let eventParser = ChatEventParser(persistenceController: self.persistenceController, logger: TestLogger())
        
        XCTAssertNotNil(eventParser.persistenceController)
        XCTAssertTrue(eventParser.logger is TestLogger)
    }
    
    func testShouldNotParseEventFromUnsupportedService() {
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: self.event, from: .presence, version: .version6) { error in
            guard let error = error as? NetworkingError else {
                return
            }
            
            XCTAssertEqual(error, NetworkingError.invalidEvent)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 0)
        }
    }
    
    func testShouldNotParseEventFromUnsupportedServiceVersion() {
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: self.event, from: .chat, version: .version2) { error in
            guard let error = error as? NetworkingError else {
                return
            }
            
            XCTAssertEqual(error, NetworkingError.invalidEvent)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 0)
        }
    }
    
    func testShouldCorrectlyParseValidInitialStateEvent() {
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: self.event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 2)
            
            guard let firstRoom = mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa") else {
                XCTFail("Failed to fetch room.")
                return
            }
            
            XCTAssertEqual(firstRoom.identifier, "124c6cdb-80f9-47f4-820f-23684bddbffa")
            XCTAssertEqual(firstRoom.name, "Fancy room")
            XCTAssertFalse(firstRoom.isPrivate)
            XCTAssertEqual(firstRoom.unreadCount, 1)
            XCTAssertEqual(firstRoom.createdAt, DateFormatter.default.date(from: "2019-08-30T21:37:07Z"))
            XCTAssertEqual(firstRoom.updatedAt, DateFormatter.default.date(from: "2019-08-30T21:37:07Z"))
            XCTAssertNil(firstRoom.deletedAt)
            XCTAssertNil(firstRoom.creator)
            XCTAssertEqual(firstRoom.members?.count, 0)
            XCTAssertEqual(firstRoom.messages?.count, 0)
            XCTAssertEqual(firstRoom.cursors?.count, 0)
            XCTAssertEqual(firstRoom.typingMembers?.count, 0)
            XCTAssertNil(firstRoom.metadata)
            
            guard let secondRoom = mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "831b637a-bdd2-47cc-aa57-99912a16df42") else {
                XCTFail("Failed to fetch room.")
                return
            }
            
            XCTAssertEqual(secondRoom.identifier, "831b637a-bdd2-47cc-aa57-99912a16df42")
            XCTAssertEqual(secondRoom.name, "Test room")
            XCTAssertTrue(secondRoom.isPrivate)
            XCTAssertEqual(secondRoom.unreadCount, 1)
            XCTAssertEqual(secondRoom.createdAt, DateFormatter.default.date(from: "2019-09-06T09:29:15Z"))
            XCTAssertEqual(secondRoom.updatedAt, DateFormatter.default.date(from: "2019-09-06T09:29:25Z"))
            XCTAssertEqual(secondRoom.deletedAt, DateFormatter.default.date(from: "2019-09-06T09:29:35Z"))
            XCTAssertNil(secondRoom.creator)
            XCTAssertEqual(secondRoom.members?.count, 0)
            XCTAssertEqual(secondRoom.messages?.count, 0)
            XCTAssertEqual(secondRoom.cursors?.count, 0)
            XCTAssertEqual(secondRoom.typingMembers?.count, 0)
            XCTAssertNotNil(secondRoom.metadata)
            XCTAssertEqual(MetadataSerializer.deserialize(data: secondRoom.metadata) as? [String : String], self.metadataPayload)
        }
    }
    
    func testShouldNotModifyExistingRoomsWithDifferentIdentifiers() {
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let room = mainContext.create(RoomEntity.self)
            room.identifier = "bdd247cc-831b-637a-9991-aa572a16df42"
            room.name = "Old room"
            room.isPrivate = true
            room.unreadCount = 8
            room.createdAt = Date.distantPast
            room.updatedAt = Date.distantPast
            room.metadata = MetadataSerializer.serialize(metadata: self.metadataPayload)
        }
        
        self.persistenceController.save()
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: self.event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 3)
            
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "831b637a-bdd2-47cc-aa57-99912a16df42"))
            
            guard let oldRoom = mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "bdd247cc-831b-637a-9991-aa572a16df42") else {
                XCTFail("Failed to fetch room.")
                return
            }
            
            XCTAssertEqual(oldRoom.identifier, "bdd247cc-831b-637a-9991-aa572a16df42")
            XCTAssertEqual(oldRoom.name, "Old room")
            XCTAssertTrue(oldRoom.isPrivate)
            XCTAssertEqual(oldRoom.unreadCount, 8)
            XCTAssertEqual(oldRoom.createdAt, Date.distantPast)
            XCTAssertEqual(oldRoom.updatedAt, Date.distantPast)
            XCTAssertNil(oldRoom.deletedAt)
            XCTAssertNil(oldRoom.creator)
            XCTAssertEqual(oldRoom.members?.count, 0)
            XCTAssertEqual(oldRoom.messages?.count, 0)
            XCTAssertEqual(oldRoom.cursors?.count, 0)
            XCTAssertEqual(oldRoom.typingMembers?.count, 0)
            XCTAssertNotNil(oldRoom.metadata)
            XCTAssertEqual(MetadataSerializer.deserialize(data: oldRoom.metadata) as? [String : String], self.metadataPayload)
        }
    }
    
    func testShouldUpdateExistingRoomWithTheSameIdentifier() {
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let room = mainContext.create(RoomEntity.self)
            room.identifier = "124c6cdb-80f9-47f4-820f-23684bddbffa"
            room.name = "Old room"
            room.isPrivate = true
            room.unreadCount = 8
            room.createdAt = Date.distantPast
            room.updatedAt = Date.distantPast
            room.metadata = MetadataSerializer.serialize(metadata: self.metadataPayload)
        }
        
        self.persistenceController.save()
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: self.event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 2)
            
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "831b637a-bdd2-47cc-aa57-99912a16df42"))
            
            guard let oldRoom = mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa") else {
                XCTFail("Failed to fetch room.")
                return
            }
            
            XCTAssertEqual(oldRoom.identifier, "124c6cdb-80f9-47f4-820f-23684bddbffa")
            XCTAssertEqual(oldRoom.name, "Fancy room")
            XCTAssertFalse(oldRoom.isPrivate)
            XCTAssertEqual(oldRoom.unreadCount, 1)
            XCTAssertEqual(oldRoom.createdAt, DateFormatter.default.date(from: "2019-08-30T21:37:07Z"))
            XCTAssertEqual(oldRoom.updatedAt, DateFormatter.default.date(from: "2019-08-30T21:37:07Z"))
            XCTAssertNil(oldRoom.deletedAt)
            XCTAssertNil(oldRoom.creator)
            XCTAssertEqual(oldRoom.members?.count, 0)
            XCTAssertEqual(oldRoom.messages?.count, 0)
            XCTAssertEqual(oldRoom.cursors?.count, 0)
            XCTAssertEqual(oldRoom.typingMembers?.count, 0)
            XCTAssertNil(oldRoom.metadata)
        }
    }
    
    func testShouldSkipRoomWithInvalidIdentifier() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : 1234,
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithMissingIdentifier() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithInvalidName() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : 1,
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithMissingName() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithMissingPrivateKey() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithInvalidUnreadCount() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : "1",
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithMissingUnreadCount() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithInvalidCreatedAt() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "randomString",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithMissingCreatedAt() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithInvalidUpdatedAt() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "randomString"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipRoomWithMissingUpdatedAt() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 1)
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
        }
    }
    
    func testShouldSkipInvalidDeletedAtKey() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : self.metadataPayload,
                                                             "deleted_at" : "randomString",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 2)
            
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
            
            guard let room = mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "831b637a-bdd2-47cc-aa57-99912a16df42") else {
                XCTFail("Failed to fetch room.")
                return
            }
            
            XCTAssertEqual(room.identifier, "831b637a-bdd2-47cc-aa57-99912a16df42")
            XCTAssertEqual(room.name, "Test room")
            XCTAssertTrue(room.isPrivate)
            XCTAssertEqual(room.unreadCount, 1)
            XCTAssertEqual(room.createdAt, DateFormatter.default.date(from: "2019-09-06T09:29:15Z"))
            XCTAssertEqual(room.updatedAt, DateFormatter.default.date(from: "2019-09-06T09:29:25Z"))
            XCTAssertNil(room.deletedAt)
            XCTAssertNil(room.creator)
            XCTAssertEqual(room.members?.count, 0)
            XCTAssertEqual(room.messages?.count, 0)
            XCTAssertEqual(room.cursors?.count, 0)
            XCTAssertEqual(room.typingMembers?.count, 0)
            XCTAssertNotNil(room.metadata)
            XCTAssertEqual(MetadataSerializer.deserialize(data: room.metadata) as? [String : String], self.metadataPayload)
        }
    }
    
    func testShouldSkipInvalidMetadata() {
        guard let event = Event(with: ["event_name" : "initial_state",
                                       "data" : ["current_user" : ["id" : "alice",
                                                                   "name" : "alice",
                                                                   "created_at" : "2019-08-30T21:06:09Z",
                                                                   "updated_at" : "2019-08-30T21:06:09Z"],
                                                 "cursors" : [],
                                                 "rooms" : [["created_at" : "2019-08-30T21:37:07Z",
                                                             "created_by_id" : "alice",
                                                             "id" : "124c6cdb-80f9-47f4-820f-23684bddbffa",
                                                             "last_message_at" : "2019-09-03T10:40:38Z",
                                                             "member_user_ids" : nil,
                                                             "name" : "Fancy room",
                                                             "private" : false,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-08-30T21:37:07Z"],
                                                            ["created_at" : "2019-09-06T09:29:15Z",
                                                             "created_by_id" : "bob",
                                                             "custom_data" : ["firstValue", "secondValue"],
                                                             "deleted_at" : "2019-09-06T09:29:35Z",
                                                             "id" : "831b637a-bdd2-47cc-aa57-99912a16df42",
                                                             "member_user_ids" : nil,
                                                             "name" : "Test room",
                                                             "private" : true,
                                                             "unread_count" : 1,
                                                             "updated_at" : "2019-09-06T09:29:25Z"]]],
                                       "timestamp": "2019-09-06T09:30:01Z"]) else {
                                        assertionFailure("Failed to instantiate event.")
                                        return
        }
        
        let eventParser = ChatEventParser(persistenceController: self.persistenceController)
        
        let expectation = self.expectation(description: "Parsing")
        
        eventParser.parse(event: event, from: .chat, version: .version6) { error in
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
        
        let mainContext = self.persistenceController.mainContext
        
        mainContext.performAndWait {
            let count = mainContext.count(RoomEntity.self)
            
            XCTAssertEqual(count, 2)
            
            XCTAssertNotNil(mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "124c6cdb-80f9-47f4-820f-23684bddbffa"))
            
            guard let room = mainContext.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), "831b637a-bdd2-47cc-aa57-99912a16df42") else {
                XCTFail("Failed to fetch room.")
                return
            }
            
            XCTAssertEqual(room.identifier, "831b637a-bdd2-47cc-aa57-99912a16df42")
            XCTAssertEqual(room.name, "Test room")
            XCTAssertTrue(room.isPrivate)
            XCTAssertEqual(room.unreadCount, 1)
            XCTAssertEqual(room.createdAt, DateFormatter.default.date(from: "2019-09-06T09:29:15Z"))
            XCTAssertEqual(room.updatedAt, DateFormatter.default.date(from: "2019-09-06T09:29:25Z"))
            XCTAssertEqual(room.deletedAt, DateFormatter.default.date(from: "2019-09-06T09:29:35Z"))
            XCTAssertNil(room.creator)
            XCTAssertEqual(room.members?.count, 0)
            XCTAssertEqual(room.messages?.count, 0)
            XCTAssertEqual(room.cursors?.count, 0)
            XCTAssertEqual(room.typingMembers?.count, 0)
            XCTAssertNil(room.metadata)
        }
    }
    
}
