import TestUtilities
import XCTest
@testable import PusherChatkit

class WireEventMessageDeletedDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "message_id": "53457983",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.MessageDeleted(from: jsonData.jsonDecoder())) { event in
            XCTAssertEqual(event.messageIdentifier, "53457983")
        }
    }
    
    func test_init_messageIdentifierMissing_throws() {
        
        let jsonData = """
        {
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.MessageDeleted(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"message_id\""])
    }
    
    func test_init_messageIdentifierNull_throws() {
        
        let jsonData = """
        {
            "message_id": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.MessageDeleted(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"message_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_messageIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "message_id": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.MessageDeleted(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"message_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
}
