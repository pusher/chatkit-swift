import XCTest
@testable import PusherChatkit

class WireUserDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertEqual(room.identifier, "cool-room-1")
            XCTAssertEqual(room.name, "mycoolroom")
            XCTAssertEqual(room.avatarUrl, URL(string: "https://images.com/avatar"))
            XCTAssertEqual(room.customData as? [String: Bool], ["cool": true])
            XCTAssertEqual(room.createdAt, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            XCTAssertEqual(room.updatedAt, Date(fromISO8601String: "2017-04-23T11:36:42Z"))
            XCTAssertEqual(room.deletedAt, Date(fromISO8601String: "2017-05-23T11:36:42Z"))
        }
    }
    
    func test_init_identifierMissing_throws() {
        
        let jsonData = """
        {
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
    func test_init_identifierNull_throws() {
        
        let jsonData = """
        {
            "id": null,
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_identifierInvalidType_throws() {
        
        let jsonData = """
        {
            "id": 123,
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_nameMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"name\""])
    }
    
    func test_init_nameNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": null,
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"name\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_nameInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": 123,
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"name\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_avatarUrlMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertEqual(room.avatarUrl, nil)
        }
    }
    
    func test_init_avatarUrlNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": null,
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertEqual(room.avatarUrl, nil)
        }
    }
    
    func test_init_avatarUrlInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": 123,
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"avatar_url\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_customDataMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertNil(room.customData)
        }
    }
    
    func test_init_customDataNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": null,
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertNil(room.customData)
        }
    }
    
    func test_init_customDataInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": 123,
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"custom_data\"",
                                          "Expected to decode Dictionary<String, Any> but found a number instead."])
    }
    
    func test_init_createdAtMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"created_at\""])
    }
    
    func test_init_createdAtNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": null,
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"created_at\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_createdAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": 123,
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"created_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_createdAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "not a date",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"created_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
    func test_init_updatedAtMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"updated_at\""])
    }
    
    func test_init_updatedAtNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": null,
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"updated_at\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_updatedAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": 123,
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"updated_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_updatedAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "not a date",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"updated_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
    func test_init_deletedAtMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertEqual(room.deletedAt, nil)
        }
    }
    
    func test_init_deletedAtNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": null,
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.User(from: jsonData.jsonDecoder())) { room in
            XCTAssertEqual(room.deletedAt, nil)
        }
    }
    
    func test_init_deletedAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"deleted_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_deletedAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "avatar_url": "https://images.com/avatar",
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "not a date",
        }
        """.toJsonData()
    
        XCTAssertThrowsError(try Wire.User(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"deleted_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
}
