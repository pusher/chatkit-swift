import XCTest
@testable import PusherChatkit

class WireEventUserJoinedRoomDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
            "user_id": "alice",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder())) { event in
            XCTAssertEqual(event.roomIdentifier, "cool-room-2")
            XCTAssertEqual(event.userIdentifier, "alice")
        }
    }
    
    func test_init_roomIdentifierMissing_throws() {
        
        let jsonData = """
        {
            "user_ids": "alice",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder()),
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
        
        XCTAssertThrowsError(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder()),
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
        
        XCTAssertThrowsError(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_userIdentifiersMissing_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"user_id\""])
    }
    
    func test_init_userIdentifiersNull_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
            "user_id": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"user_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_userIdentifiersInvalidType_throws() {
        
        let jsonData = """
        {
            "room_id": "cool-room-2",
            "user_id": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.UserJoinedRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"user_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
}
