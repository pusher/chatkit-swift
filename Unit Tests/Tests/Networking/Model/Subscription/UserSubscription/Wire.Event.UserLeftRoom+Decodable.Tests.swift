import XCTest
@testable import PusherChatkit

class WireEventUserLeftRoomDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": "alice",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder())) { event in
            XCTAssertEqual(event.roomIdentifier, "ac43dfef")
            XCTAssertEqual(event.userIdentifier, "alice")
        }
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "user_ids": "alice",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_roomIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": null,
            "user_id": "alice",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_roomIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": 123,
            "user_id": "alice",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_userIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_id\""])
    }
    
    func test_init_userIdentifierNull_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_userIdentifierInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "ac43dfef",
            "user_id": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserLeftRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
}
