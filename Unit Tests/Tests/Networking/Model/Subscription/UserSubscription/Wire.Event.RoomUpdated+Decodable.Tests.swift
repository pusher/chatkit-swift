import XCTest
@testable import PusherChatkit

class WireEventRoomUpdatedDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room": {
                "id": "ac43dfef",
                "name": "Chatkit chat",
                "created_by_id": "alice",
                "private": false,
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-04-23T11:36:42Z",
            },
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.RoomUpdated(from: jsonData.jsonDecoder())) { event in
            // Loosely verify the `room` (parsing of this entity is comprehensively tested elsewhere)
            XCTAssertNotNil(event.room)
        }
    }
    
    func test_init_roomMissing_throws() {
        
        let jsonData = """
        {
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RoomUpdated(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room\""])
    }
    
    func test_init_roomNull_throws() {
        
        let jsonData = """
        {
            "room": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RoomUpdated(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_roomInvalidType_throws() {
        
        let jsonData = """
        {
            "room": "not a room",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RoomUpdated(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_roomInvalidFormat_throws() {
        
        // Note the `room` is missing its mandatory `id`
        let jsonData = """
        {
            "room": {
                "name": "Chatkit chat",
                "created_by_id": "alice",
                "private": false,
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-04-23T11:36:42Z",
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.RoomUpdated(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
}
