import XCTest
@testable import PusherChatkit

class UserTests: XCTestCase {
    
    // MARK: - Properties
    
    var firstTestURL: URL!
    var secondTestURL: URL!
    
    var firstTestCustomData: CustomData!
    var secondTestCustomData: CustomData!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        self.firstTestURL = URL(fileURLWithPath: "/dev/null")
        self.secondTestURL = URL(fileURLWithPath: "/dev/zero")
        
        self.firstTestCustomData = ["firstKey" : "firstValue"]
        self.secondTestCustomData = ["secondKey" : "secondValue"]
    }
    
    // MARK: - Tests
    
    func testShouldCreateUserWithCorrectValues() {
        let user = User(identifier: "testIdentifier",
                        name: "testName",
                        avatar: self.firstTestURL,
                        presenceState: .offline,
                        customData: self.firstTestCustomData,
                        createdAt: Date.distantPast,
                        updatedAt: Date.distantFuture)
        
        XCTAssertEqual(user.identifier, "testIdentifier")
        XCTAssertEqual(user.name, "testName")
        XCTAssertEqual(user.avatar, self.firstTestURL)
        XCTAssertEqual(user.presenceState, PresenceState.offline)
        XCTAssertNotNil(user.customData)
        XCTAssertEqual(user.customData as? [String : String], self.firstTestCustomData as? [String : String])
        XCTAssertEqual(user.createdAt, Date.distantPast)
        XCTAssertEqual(user.updatedAt, Date.distantFuture)
    }
    
    func testUserShouldHaveTheSameHashForTheSameIdentifiers() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "anotherName",
                              avatar: self.secondTestURL,
                              presenceState: .online,
                              customData: self.secondTestCustomData,
                              createdAt: Date.distantFuture,
                              updatedAt: Date.distantPast)
        
        XCTAssertEqual(firstUser.hashValue, secondUser.hashValue)
    }
    
    func testUserShouldOnlyUseIdentifierToGenerateHash() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "anotherIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertNotEqual(firstUser.hashValue, secondUser.hashValue)
    }
    
    func testShouldCompareTwoUsersAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertEqual(firstUser, secondUser)
    }
    
    func testShouldNotCompareTwoUsersAsEqualWhenIdentifierValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "anotherIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertNotEqual(firstUser, secondUser)
    }
    
    func testShouldNotCompareTwoUsersAsEqualWhenNameValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "anotherName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertNotEqual(firstUser, secondUser)
    }
    
    func testShouldNotCompareTwoUsersAsEqualWhenAvatarValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "testName",
                              avatar: self.secondTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertNotEqual(firstUser, secondUser)
    }
    
    func testShouldNotCompareTwoUsersAsEqualWhenPresenceStateValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .online,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertNotEqual(firstUser, secondUser)
    }
    
    func testShouldCompareTwoUsersAsEqualWhenCustomDataValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.secondTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantFuture)
        
        XCTAssertEqual(firstUser, secondUser)
    }
    
    func testShouldNotCompareTwoUsersAsEqualWhenCreatedAtValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantFuture,
                              updatedAt: Date.distantFuture)
        
        XCTAssertNotEqual(firstUser, secondUser)
    }
    
    func testShouldNotCompareTwoUsersAsEqualWhenUpdatedAtValuesAreDifferent() {
        let firstUser = User(identifier: "testIdentifier",
                             name: "testName",
                             avatar: self.firstTestURL,
                             presenceState: .offline,
                             customData: self.firstTestCustomData,
                             createdAt: Date.distantPast,
                             updatedAt: Date.distantFuture)
        
        let secondUser = User(identifier: "testIdentifier",
                              name: "testName",
                              avatar: self.firstTestURL,
                              presenceState: .offline,
                              customData: self.firstTestCustomData,
                              createdAt: Date.distantPast,
                              updatedAt: Date.distantPast)
        
        XCTAssertNotEqual(firstUser, secondUser)
    }
    
}
