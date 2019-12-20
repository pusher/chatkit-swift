import XCTest
@testable import PusherChatkit

class WireRoomDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.identifier, "cool-room-1")
            XCTAssertEqual(user.name, "mycoolroom")
            XCTAssertEqual(user.createdById, "jean")
            XCTAssertEqual(user.pushNotificationTitleOverride, "Cool Room")
            XCTAssertEqual(user.isPrivate, false)
            XCTAssertEqual(user.customData as? [String: Bool], ["cool": true])
            XCTAssertEqual(user.lastMessageAt, Date(fromISO8601String: "2017-02-23T11:36:42Z"))
            XCTAssertEqual(user.createdAt, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            XCTAssertEqual(user.updatedAt, Date(fromISO8601String: "2017-04-23T11:36:42Z"))
            XCTAssertEqual(user.deletedAt, Date(fromISO8601String: "2017-05-23T11:36:42Z"))
        }
    }
    
    func test_init_idMissing_throws() {
        
        let jsonData = """
        {
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
    func test_init_idNull_throws() {
        
        let jsonData = """
        {
            "id": null,
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_idInvalidType_throws() {
        
        let jsonData = """
        {
            "id": 123,
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_nameMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"name\""])
    }
    
    func test_init_nameNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": null,
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"name\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_nameInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": 123,
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"name\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_createdByIdMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"created_by_id\""])
    }
    
    func test_init_createdByIdNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": null,
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"created_by_id\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_createdByIdInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": 123,
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"created_by_id\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_customDataMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertNil(user.customData)
        }
    }
    
    func test_init_customDataNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": null,
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertNil(user.customData)
        }
    }
    
    func test_init_customDataInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": 123,
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"custom_data\"",
                                          "Expected to decode Dictionary<String, Any> but found a number instead."])
    }
    
    func test_init_customDataInvalidFormat_throws() {
        
        // I've not worked out a way to create an invalid `custom_data` object that isn't invalid
        // JSON itself, so this test will have to suffice (the JSON string is invalid).
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "missing value"
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData(validate: false) // NOTE this deliberately uses `validate: false`
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["The given data was not valid JSON.",
                                          "No value for key in object around character 206."])
    }
    
    func test_init_pushNotificationTitleOverrideMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.pushNotificationTitleOverride, nil)
        }
    }
    
    func test_init_pushNotificationTitleOverrideNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": null,
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.pushNotificationTitleOverride, nil)
        }
    }
    
    func test_init_pushNotificationTitleOverrideInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": 123,
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"push_notification_title_override\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_isPrivateMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"private\""])
    }
    
    func test_init_isPrivateNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": null,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"private\"",
                                          "Expected Bool value but found null instead."])
    }
    
    func test_init_isPrivateInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": 123,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"private\"",
                                          "Expected to decode Bool but found a number instead."])
    }
    
    func test_init_lastMessageAtMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.lastMessageAt, nil)
        }
    }
    
    func test_init_lastMessageAtNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": null,
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.lastMessageAt, nil)
        }
    }
    
    func test_init_lastMessageAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": 123,
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"last_message_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_lastMessageAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "not a date",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
    
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"last_message_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
    func test_init_createdAtMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"created_at\""])
    }
    
    func test_init_createdAtNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": null,
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"created_at\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_createdAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": 123,
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"created_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_createdAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "not a date",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"created_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
    func test_init_updatedAtMissing_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"updated_at\""])
    }
    
    func test_init_updatedAtNull_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": null,
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"updated_at\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_updatedAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": 123,
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"updated_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_updatedAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "not a date",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"updated_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
    func test_init_deletedAtMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.deletedAt, nil)
        }
    }
    
    func test_init_deletedAtNull_noProblem() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": null,
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.deletedAt, nil)
        }
    }
    
    func test_init_deletedAtInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"deleted_at\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_deletedAtInvalidFormat_throws() {
        
        let jsonData = """
        {
            "id": "cool-room-1",
            "name": "mycoolroom",
            "created_by_id": "jean",
            "push_notification_title_override": "Cool Room",
            "private": false,
            "custom_data": {
                "cool": true
            },
            "last_message_at": "2017-02-23T11:36:42Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "not a date",
        }
        """.toJsonData()
    
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"deleted_at\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
}
