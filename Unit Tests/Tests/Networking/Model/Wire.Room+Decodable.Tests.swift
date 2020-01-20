import XCTest
@testable import PusherChatkit

class WireRoomDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Room(from: jsonData.jsonDecoder())) { user in
            XCTAssertEqual(user.identifier, "ac43dfef")
            XCTAssertEqual(user.name, "Chatkit chat")
            XCTAssertEqual(user.createdById, "alice")
            XCTAssertEqual(user.pushNotificationTitleOverride, "Chatkit")
            XCTAssertEqual(user.isPrivate, false)
            XCTAssertEqual(user.customData as? [String: String], ["highlight_color": "blue"])
            XCTAssertEqual(user.lastMessageAt, Date(fromISO8601String: "2020-01-08T14:55:10Z"))
            XCTAssertEqual(user.createdAt, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            XCTAssertEqual(user.updatedAt, Date(fromISO8601String: "2017-04-23T11:36:42Z"))
            XCTAssertEqual(user.deletedAt, Date(fromISO8601String: "2017-05-23T11:36:42Z"))
        }
    }
    
    func test_init_idMissing_throws() {
        
        let jsonData = """
        {
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": null,
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": 123,
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": null,
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": 123,
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
    
    func test_init_pushNotificationTitleOverrideMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": null,
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": 123,
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
    
    func test_init_customDataMissing_noProblem() {
        
        let jsonData = """
        {
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": null,
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": 123,
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
                "missing value"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",
        }
        """.toJsonData(validate: false) // NOTE this deliberately uses `validate: false`
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["The given data was not valid JSON.",
                                          "No value for key in object around character 206."])
    }
    
    func test_init_isPrivateMissing_throws() {
        
        let jsonData = """
        {
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": null,
            "last_message_at": "2020-01-08T14:55:10Z",
            "created_at": "2017-03-23T11:36:42Z",
            "updated_at": "2017-04-23T11:36:42Z",
            "deleted_at": "2017-05-23T11:36:42Z",        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Room(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"private\"",
                                          "Expected Bool value but found null instead."])
    }
    
    func test_init_isPrivateInvalidType_throws() {
        
        let jsonData = """
        {
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": 123,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
            "id": "ac43dfef",
            "name": "Chatkit chat",
            "created_by_id": "alice",
            "push_notification_title_override": "Chatkit",
            "custom_data": {
              "highlight_color": "blue"
            },
            "private": false,
            "last_message_at": "2020-01-08T14:55:10Z",
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
