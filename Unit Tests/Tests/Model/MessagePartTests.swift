import XCTest
@testable import PusherChatkit

class MessagePartTests: XCTestCase {
    
    // MARK: - Properties
    
    var firstTestURL: URL!
    var secondTestURL: URL!
    
    var firstTestUserData: UserData!
    var secondTestUserData: UserData!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        self.firstTestURL = URL(fileURLWithPath: "/dev/null")
        self.secondTestURL = URL(fileURLWithPath: "/dev/zero")
        
        self.firstTestUserData = ["firstKey" : "firstValue"]
        self.secondTestUserData = ["secondKey" : "secondValue"]
    }
    
    // MARK: - Tests
    
    func testShouldCreateTextMessagePartWithCorrectValues() {
        let messagePart = MessagePart.inline("text/plain", "testContent")
        
        if case let MessagePart.inline(mimeType, content) = messagePart {
            XCTAssertEqual(mimeType, "text/plain")
            XCTAssertEqual(content, "testContent")
        }
        else {
            XCTFail("Failed to create text part.")
        }
    }
    
    func testShouldCreateLinkMessagePartWithCorrectValues() {
        let messagePart = MessagePart.link("image/png", self.firstTestURL)
        
        if case let MessagePart.link(mimeType, url) = messagePart {
            XCTAssertEqual(mimeType, "image/png")
            XCTAssertEqual(url, self.firstTestURL)
        }
        else {
            XCTFail("Failed to create link part.")
        }
    }
    
    func testShouldCreateAttachmentMessagePartWithCorrectValues() {
        let messagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        if case let MessagePart.attachment(mimeType, identifier, downloadURL, refreshURL, size, expiration, name, userData) = messagePart {
            XCTAssertEqual(mimeType, "image/png")
            XCTAssertEqual(identifier, "testIdentifier")
            XCTAssertEqual(downloadURL, self.firstTestURL)
            XCTAssertEqual(refreshURL, self.secondTestURL)
            XCTAssertEqual(size, 1234)
            XCTAssertEqual(expiration, Date.distantFuture)
            XCTAssertEqual(name, "testName")
            XCTAssertNotNil(userData)
            XCTAssertEqual(userData as? [String : String], self.firstTestUserData as? [String : String])
        }
        else {
            XCTFail("Failed to create attachment part.")
        }
    }
    
    func testShouldHaveTheSameHashForTheSameTextMessageParts() {
        let firstMessagePart = MessagePart.inline("text/plain", "testContent")
        let secondMessagePart = MessagePart.inline("text/plain", "testContent")
        
        XCTAssertEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForTextMessagePartsWithDifferentMIMETypeValues() {
        let firstMessagePart = MessagePart.inline("text/plain", "testContent")
        let secondMessagePart = MessagePart.inline("text/json", "testContent")
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForTextMessagePartsWithDifferentContentValues() {
        let firstMessagePart = MessagePart.inline("text/plain", "testContent")
        let secondMessagePart = MessagePart.inline("text/plain", "anotherContent")
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldHaveTheSameHashForTheSameLinkMessageParts() {
        let firstMessagePart = MessagePart.link("image/png", self.firstTestURL)
        let secondMessagePart = MessagePart.link("image/png", self.firstTestURL)
        
        XCTAssertEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForLinkMessagePartsWithDifferentMIMETypeValues() {
        let firstMessagePart = MessagePart.link("image/png", self.firstTestURL)
        let secondMessagePart = MessagePart.link("image/jpeg", self.firstTestURL)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForLinkMessagePartsWithDifferentURLValues() {
        let firstMessagePart = MessagePart.link("image/png", self.firstTestURL)
        let secondMessagePart = MessagePart.link("image/png", self.secondTestURL)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldHaveTheSameHashForTheSameAttachmentMessageParts() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentMIMETypeValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/jpeg", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentIdentifierValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "anotherIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentDownloadURLValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.secondTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentRefreshURLValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.firstTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentSizeValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 9876, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentExpirationValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantPast, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotHaveTheSameHashForAttachmentMessagePartsWithDifferentNameValues() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "anotherName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldNotIncludeUserDataValueWhenCalculatingHashForAttachmentMessageParts() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.secondTestUserData)
        
        XCTAssertEqual(firstMessagePart.hashValue, secondMessagePart.hashValue)
    }
    
    func testShouldCompareTwoTextMessagePartsAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstMessagePart = MessagePart.inline("text/plain", "testContent")
        let secondMessagePart = MessagePart.inline("text/plain", "testContent")
        
        XCTAssertEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoTextMessagePartsAsEqualWhenMIMETypeValuesAreDifferent() {
        let firstMessagePart = MessagePart.inline("text/plain", "testContent")
        let secondMessagePart = MessagePart.inline("text/json", "testContent")
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoTextMessagePartsAsEqualWhenContentValuesAreDifferent() {
        let firstMessagePart = MessagePart.inline("text/plain", "testContent")
        let secondMessagePart = MessagePart.inline("text/plain", "anotherContent")
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldCompareTwoLinkMessagePartsAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstMessagePart = MessagePart.link("image/png", self.firstTestURL)
        let secondMessagePart = MessagePart.link("image/png", self.firstTestURL)
        
        XCTAssertEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoLinkMessagePartsAsEqualWhenMIMETypeValuesAreDifferent() {
        let firstMessagePart = MessagePart.link("image/png", self.firstTestURL)
        let secondMessagePart = MessagePart.link("image/jpeg", self.firstTestURL)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoLinkMessagePartsAsEqualWhenURLValuesAreDifferent() {
        let firstMessagePart = MessagePart.link("image/png", self.firstTestURL)
        let secondMessagePart = MessagePart.link("image/png", self.secondTestURL)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldCompareTwoAttachmentMessagePartsAsEqualWhenValuesOfAllPropertiesAreTheSame() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenMIMETypeValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/jpeg", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenIdentifierValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "anotherIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenDownloadURLValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.secondTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenRefreshURLValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.firstTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenSizeValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 9876, Date.distantFuture, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenExpirationValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantPast, "testName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldNotCompareTwoAttachmentMessagePartsAsEqualWhenNameValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "anotherName", self.firstTestUserData)
        
        XCTAssertNotEqual(firstMessagePart, secondMessagePart)
    }
    
    func testShouldCompareTwoAttachmentMessagePartsAsEqualWhenUserDataValuesAreDifferent() {
        let firstMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.firstTestUserData)
        let secondMessagePart = MessagePart.attachment("image/png", "testIdentifier", self.firstTestURL, self.secondTestURL, 1234, Date.distantFuture, "testName", self.secondTestUserData)
        
        XCTAssertEqual(firstMessagePart, secondMessagePart)
    }
    
}
