import XCTest
@testable import PusherChatkit

class WireEventReadStateUpdatedDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "read_state": {
                "room_id": "cool-room-1",
                "unread_count": 90,
                "cursor": {
                    "room_id": "cool-room-1",
                    "user_id": "viv",
                    "cursor_type": 0,
                    "position": 154,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.ReadStateUpdated(from: jsonData.jsonDecoder())) { event in
            // Loosely verify the `read_state` (parsing of this entity is comprehensively tested elsewhere)
            XCTAssertNotNil(event.readState)
        }
    }
    
    func test_init_readStateMissing_throws() {
        
        let jsonData = """
        {
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.ReadStateUpdated(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"read_state\""])
    }
    
    func test_init_readStateNull_throws() {
        
        let jsonData = """
        {
            "read_state": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.ReadStateUpdated(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"read_state\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_readStateInvalidType_throws() {
        
        let jsonData = """
        {
            "read_state": "not a read_state",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.ReadStateUpdated(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"read_state\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_readStateInvalidFormat_throws() {
        
        // Note the `readState` is missing its mandatory `room_id`
        let jsonData = """
        {
            "read_state": {
                "unread_count": 90,
                "cursor": {
                    "room_id": "cool-room-1",
                    "user_id": "viv",
                    "cursor_type": 0,
                    "position": 154,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.ReadStateUpdated(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
}
