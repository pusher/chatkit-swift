import XCTest
import PusherPlatform
@testable import PusherChatkit

class StoreTests: XCTestCase {
    
    // MARK: - Properties
    
    var store: Store<UserEntity>!
    
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
        
        self.store = Store(persistenceController: persistenceController)
        
        persistenceController.mainContext.performAndWait {
            let firstUserEntity = persistenceController.mainContext.create(UserEntity.self)
            firstUserEntity.identifier = "firstIdentifier"
            firstUserEntity.createdAt = Date()
            firstUserEntity.updatedAt = firstUserEntity.createdAt
            
            let secondUserEntity = persistenceController.mainContext.create(UserEntity.self)
            secondUserEntity.identifier = "secondIdentifier"
            secondUserEntity.createdAt = Date()
            secondUserEntity.updatedAt = firstUserEntity.createdAt
            
            let thirdUserEntity = persistenceController.mainContext.create(UserEntity.self)
            thirdUserEntity.identifier = "thirdIdentifier"
            thirdUserEntity.createdAt = Date()
            thirdUserEntity.updatedAt = firstUserEntity.createdAt
        }
        
        persistenceController.save()
    }
    
    // MARK: - Tests
    
    func testShouldReturnRandomUser() {
        let acceptableResults = Set(["firstIdentifier", "secondIdentifier", "thirdIdentifier"])
        
        guard let user = self.store.object() else {
            XCTFail("Store should return random user from the persistence controller.")
            return
        }
        
        XCTAssertTrue(acceptableResults.contains(user.identifier))
    }
    
    func testShouldReturnCorrectUserFileredByPredicate() {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(UserEntity.identifier), "secondIdentifier")
        
        let user = self.store.object(for: predicate)
        
        XCTAssertEqual(user?.identifier, "secondIdentifier")
    }
    
    func testShouldReturnFirstUserOrderedBySortDescriptor() {
        let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: false)
        
        let user = self.store.object(orderedBy: [sortDescriptor])
        
        XCTAssertEqual(user?.identifier, "thirdIdentifier")
    }
    
    func testShouldReturnCorrectUserFileredByPredicateAndOrderedBySortDescriptor() {
        let predicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(UserEntity.identifier), "s")
        let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: false)
        
        let user = self.store.object(for: predicate, orderedBy: [sortDescriptor])
        
        XCTAssertEqual(user?.identifier, "secondIdentifier")
    }
    
    func testShouldReturnNilWhenThereInNoMatchingUser() {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(UserEntity.identifier), "fourthIdentifier")
        
        let user = self.store.object(for: predicate)
        
        XCTAssertNil(user)
    }
    
    func testShouldReturnAllUsers() {
        let acceptableResults = Set(["firstIdentifier", "secondIdentifier", "thirdIdentifier"])
        
        guard let users = self.store.objects() else {
            XCTFail("Store should return all users from the persistence controller.")
            return
        }
        
        XCTAssertEqual(users.count, 3)
        
        XCTAssertTrue(acceptableResults.contains(users[0].identifier))
        XCTAssertTrue(acceptableResults.contains(users[1].identifier))
        XCTAssertTrue(acceptableResults.contains(users[2].identifier))
    }
    
    func testShouldReturnUsersFileredByPredicate() {
        let acceptableResults = Set(["firstIdentifier", "thirdIdentifier"])
        
        let predicate = NSPredicate(format: "%K == %d", #keyPath(UserEntity.identifier.length), 15)
        
        guard let users = self.store.objects(for: predicate) else {
            XCTFail("Store should return users from the persistence controller.")
            return
        }
        
        XCTAssertEqual(users.count, 2)
        
        XCTAssertTrue(acceptableResults.contains(users[0].identifier))
        XCTAssertTrue(acceptableResults.contains(users[0].identifier))
    }
    
    func testShouldReturnUsersOrderedBySortDescriptor() {
        let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: false)
        
        guard let users = self.store.objects(orderedBy: [sortDescriptor]) else {
            XCTFail("Store should return users from the persistence controller.")
            return
        }
        
        XCTAssertEqual(users.count, 3)
        
        XCTAssertEqual(users[0].identifier, "thirdIdentifier")
        XCTAssertEqual(users[1].identifier, "secondIdentifier")
        XCTAssertEqual(users[2].identifier, "firstIdentifier")
    }
    
    func testShouldReturnUsersFileredByPredicateAndOrderedBySortDescriptor() {
        let predicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(UserEntity.identifier), "s")
        let sortDescriptor = NSSortDescriptor(key: #keyPath(UserEntity.identifier), ascending: false)
        
        guard let users = self.store.objects(for: predicate, orderedBy: [sortDescriptor]) else {
            XCTFail("Store should return users from the persistence controller.")
            return
        }
        
        XCTAssertEqual(users.count, 2)
        
        XCTAssertEqual(users[0].identifier, "secondIdentifier")
        XCTAssertEqual(users[1].identifier, "firstIdentifier")
    }
    
    func testShouldReturnNilWhenThereAreNoMatchingUsers() {
        let predicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(UserEntity.identifier), "z")
        
        let users = self.store.objects(for: predicate)
        
        XCTAssertNil(users)
    }
    
}
