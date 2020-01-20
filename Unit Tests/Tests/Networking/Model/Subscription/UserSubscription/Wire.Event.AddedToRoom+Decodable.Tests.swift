import XCTest
@testable import PusherChatkit

class WireEventAddedToRoomDecodableTests: XCTestCase {
    
    func test_init_allFieldsValid_entityFullyPopulated() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder())) { event in
            // Loosely verify the `room` (parsing of this entity is comprehensively tested elsewhere)
            XCTAssertNotNil(event.room)
        }
    }
    
    func test_init_roomMissing_throws() {
        
        let jsonData = """
        {
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room\""])
    }
    
    func test_init_roomNull_throws() {
        
        let jsonData = """
        {
            "room": null,
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"room\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_roomInvalidType_throws() {
        
        let jsonData = """
        {
            "room": "not a room",
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"room\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_roomInvalidFormat_throws() {
        
        // Note the `room` is missing its mandatory `id`
        let jsonData = """
        {
            "room": {
                "created_by_id": "jean",
                "name": "myamazingroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\""])
    }
    
    func test_init_membershipMissing_throws() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"membership\""])
    }
    
    func test_init_membershipNull_throws() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": null,
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"membership\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_membershipInvalidType_throws() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": "not a membership",
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"membership\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_membershipInvalidFormat_throws() {
        
        // Note the `membership` is missing its mandatory `room_id`
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "room_id": "cool-room-2",
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
    func test_init_readStateMissing_throws() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"read_state\""])
    }
    
    func test_init_readStateNull_throws() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": null
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"read_state\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_readStateInvalidType_throws() {
        
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": "not a read_state"
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"read_state\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_readStateInvalidFormat_throws() {
        
        // Note the `readState` is missing its mandatory `room_id`
        let jsonData = """
        {
            "room": {
                "id": "cool-room-2",
                "created_by_id": "ham",
                "name": "mycoolroom",
                "push_notification_title_override": null,
                "private": false,
                "custom_data": {
                    "something": "interesting"
                },
                "last_message_at": "2017-04-14T14:00:42Z",
                "created_at": "2017-03-23T11:36:42Z",
                "updated_at": "2017-03-23T11:36:42Z",
                "deleted_at": null
            },
            "membership": {
                "room_id": "cool-room-2",
                "user_ids": ["jean", "ham"]
            },
            "read_state": {
                "unread_count": 15,
                "cursor": {
                    "room_id": "cool-room-2",
                    "user_id": "alice",
                    "cursor_type": 0,
                    "position": 123654,
                    "updated_at": "2017-04-13T14:10:04Z"
                }
            }
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.AddedToRoom(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"room_id\""])
    }
    
}
