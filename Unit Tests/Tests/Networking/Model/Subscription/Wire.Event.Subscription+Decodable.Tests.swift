import XCTest
@testable import PusherChatkit

class WireSubscriptionEventDecodableTests: XCTestCase {
    
    func test_init_eventNameMissing_throws() {
        
        let jsonData = """
        {
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"event_name\""])
    }
    
    func test_init_eventNameNull_throws() {
        
        let jsonData = """
        {
            "event_name": null,
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"event_name\"",
                                          "Expected String but found null value instead."])
    }
    
    func test_init_eventNameInvalidType_throws() {
        
        let jsonData = """
        {
            "event_name": 123,
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"event_name\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_eventNameUnknown_throws() {
        
        let jsonData = """
        {
            "event_name": "unknown",
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"event_name\"",
                                          "Cannot initialize Name from invalid String value unknown"])
    }
    
    func test_init_timestampMissing_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": {
                "room_id": "cool-room-1"
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"timestamp\""])
    }
    
    func test_init_timestampNull_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"timestamp\"",
                                          "Expected Date value but found null instead."])
    }
    
    func test_init_timestampInvalidType_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"timestamp\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_timestampInvalidFormat_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": "not a valid date",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"timestamp\"",
                                          "Expected date string to be ISO8601-formatted."])
    }
    
    func test_init_dataMissing_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\""])
    }
    
    func test_init_dataNull_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": null,
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"data\"",
                                          "Cannot get keyed decoding container -- found null value instead."])
    }
    
    func test_init_dataInvalidType_throws() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": "not a dictionary",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"data\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    // MARK: - User Subscription
    
    func test_init_initialStateAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "data": {
                "current_user": {
                    "created_at": "2017-03-13T14:10:04Z",
                    "custom_data": {
                        "email": "vivan@pusher.com"
                    },
                    "id": "viv",
                    "name": "Vivan",
                    "updated_at": "2017-04-13T14:10:04Z"
                },
                "memberships": [
                    {
                        "room_id": "cool-room-1",
                        "user_ids": ["jean", "ham"]
                    },
                    {
                        "room_id": "party-room",
                        "user_ids": ["ham"]
                    }
                ],
                "read_states": [
                    {
                        "cursor": {
                            "cursor_type": 0,
                            "position": 123654,
                            "room_id": "cool-room-1",
                            "updated_at": "2017-04-13T14:10:04Z",
                            "user_id": "viv"
                        },
                        "room_id": "cool-room-1",
                        "unread_count": 7
                    }
                ],
                "rooms": [
                    {
                        "created_at": "2017-04-13T14:10:38Z",
                        "created_by_id": "jean",
                        "custom_data": {
                            "something": "interesting"
                        },
                        "deleted_at": null,
                        "id": "cool-room-1",
                        "last_message_at": "2017-04-14T14:00:42Z",
                        "name": "mycoolroom",
                        "private": false,
                        "push_notification_title_override": null,
                        "updated_at": "2017-04-13T14:10:38Z"
                    }
                ]
            },
            "event_name": "initial_state",
            "timestamp": "2017-04-14T14:00:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .initialState)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-04-14T14:00:42Z"))
            
            guard case let Wire.Event.EventType.initialState(initialState) = subscription.data else {
                XCTFail("Expected `data` value of .initialState but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(initialState.currentUser.identifier, "viv")
            XCTAssertEqual(initialState.rooms.count, 1)
            XCTAssertEqual(initialState.rooms[0].identifier, "cool-room-1")
            XCTAssertEqual(initialState.readStates.count, 1)
            XCTAssertEqual(initialState.readStates[0].unreadCount, 7)
            XCTAssertEqual(initialState.memberships.count, 2)
            XCTAssertEqual(initialState.memberships[0].userIdentifiers, ["jean", "ham"])
            XCTAssertEqual(initialState.memberships[1].userIdentifiers, ["ham"])
        }
    }
    
    func test_init_initialStateInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "initial_state",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key \\\"current_user\\\""])
    }
    
    func test_init_addedToRoomAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "data": {
                "membership": {
                    "room_id": "cool-room-2",
                    "user_ids": [
                        "jean",
                        "ham"
                    ]
                },
                "read_state": {
                    "cursor": {
                        "cursor_type": 0,
                        "position": 123654,
                        "room_id": "cool-room-2",
                        "updated_at": "2017-04-13T14:10:04Z",
                        "user_id": "viv"
                    },
                    "room_id": "cool-room-2",
                    "unread_count": 15
                },
                "room": {
                    "created_at": "2017-03-23T11:36:42Z",
                    "created_by_id": "ham",
                    "custom_data": {
                        "something": "interesting"
                    },
                    "deleted_at": null,
                    "id": "cool-room-2",
                    "last_message_at": "2017-04-14T14:00:42Z",
                    "name": "mycoolroom",
                    "private": false,
                    "push_notification_title_override": null,
                    "updated_at": "2017-03-23T11:36:42Z"
                }
            },
            "event_name": "added_to_room",
            "timestamp": "2017-04-14T14:00:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .addedToRoom)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-04-14T14:00:42Z"))
            
            guard case let Wire.Event.EventType.addedToRoom(addedToRoom) = subscription.data else {
                XCTFail("Expected `data` value of .addedToRoom but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(addedToRoom.membership.roomIdentifier, "cool-room-2")
        }
    }
    
    func test_init_addedToRoomInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "added_to_room",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"room\""])
    }
    
    func test_init_removedFromRoomAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "data": {
                "room_id": "cool-room-2"
            },
            "event_name": "removed_from_room",
            "timestamp": "2017-03-23T17:36:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .removedFromRoom)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T17:36:42Z"))
            
            guard case let Wire.Event.EventType.removedFromRoom(removedFromRoom) = subscription.data else {
                XCTFail("Expected `data` value of .removedFromRoom but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(removedFromRoom.roomIdentifier, "cool-room-2")
        }
    }
    
    func test_init_removedFromRoomInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "removed_from_room",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"room_id\""])
    }
    
    func test_init_roomUpdatedAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "room_updated",
            "data": {
                "room": {
                    "id": "cool-room-1",
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
            },
            "timestamp": "2017-04-14T14:00:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .roomUpdated)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-04-14T14:00:42Z"))
            
            guard case let Wire.Event.EventType.roomUpdated(roomUpdated) = subscription.data else {
                XCTFail("Expected `data` value of .roomUpdated but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(roomUpdated.room.identifier, "cool-room-1")
        }
    }
    
    func test_init_roomUpdatedInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "room_updated",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"room\""])
    }
    
    func test_init_roomDeletedAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "room_deleted",
            "data": {
                "room_id": "cool-room-1"
            },
            "timestamp": "2017-03-23T11:36:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .roomDeleted)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.roomDeleted(roomDeleted) = subscription.data else {
                XCTFail("Expected `data` value of .roomDeleted but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(roomDeleted.roomIdentifier, "cool-room-1")
        }
    }
    
    func test_init_roomDeletedInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "room_deleted",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"room_id\""])
    }
    
    func test_init_userJoinedRoomAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "user_joined_room",
            "data": {
                "room_id": "cool-room-1",
                "user_id": "xavier"
            },
            "timestamp": "2017-03-23T11:36:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .userJoinedRoom)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.userJoinedRoom(userJoinedRoom) = subscription.data else {
                XCTFail("Expected `data` value of .userJoinedRoom but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(userJoinedRoom.roomIdentifier, "cool-room-1")
        }
    }
    
    func test_init_userJoinedRoomInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "user_joined_room",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"room_id\""])
    }
    
    func test_init_userLeftRoomAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "user_left_room",
            "data": {
                "room_id": "cool-room-1",
                "user_id": "xavier"
            },
            "timestamp": "2017-03-23T11:36:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .userLeftRoom)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.userLeftRoom(userLeftRoom) = subscription.data else {
                XCTFail("Expected `data` value of .userLeftRoom but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(userLeftRoom.roomIdentifier, "cool-room-1")
        }
    }
    
    func test_init_userLeftRoomInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "user_left_room",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"room_id\""])
    }
    
    func test_init_readStateUpdatedAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "read_state_updated",
            "data": {
                "read_state": {
                    "cursor": {
                        "cursor_type": 0,
                        "position": 154,
                        "room_id": "cool-room-1",
                        "updated_at": "2017-04-13T14:10:04Z",
                        "user_id": "viv"
                    },
                    "room_id": "cool-room-1",
                    "unread_count": 90,
                },
            },
            "timestamp": "2017-03-23T11:36:42Z",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .readStateUpdated)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.readStateUpdated(readStateUpdated) = subscription.data else {
                XCTFail("Expected `data` value of .readStateUpdated but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(readStateUpdated.readState.roomIdentifier, "cool-room-1")
        }
    }
    
    func test_init_readStateUpdatedInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "read_state_updated",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"read_state\""])
    }
    
    
    // MARK: - Room Subscription
    
    func test_init_newMessageAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "new_message",
            "timestamp": "2017-03-23T11:36:42Z",
            "data": {
                "id": 3,
                "user_id": "viv",
                "room_id": "cool-room-1",
                "created_at":"2017-03-23T11:36:42Z",
                "updated_at":"2017-04-23T11:36:42Z",
                "parts": [
                    {
                        "type": "text/plain",
                        "content": "Hello"
                    }
                ]
            }
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .newMessage)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.newMessage(newMessage) = subscription.data else {
                XCTFail("Expected `data` value of .newMessage but got a different value instead: \(subscription.data)")
                return
            }
            
            // Loosely verify the event `data` (parsing of these entities is comprehensively tested elsewhere)
            XCTAssertEqual(newMessage.identifier, 3)
        }
    }
    
    func test_init_newMessageInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "new_message",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"id\""])
    }
    
    func test_init_isTypingAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "is_typing",
            "timestamp": "2017-03-23T11:36:42Z",
            "data": {
                "user_id": "alice"
            }
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .isTyping)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.isTyping(isTyping) = subscription.data else {
                XCTFail("Expected `data` value of .isTyping but got a different value instead: \(subscription.data)")
                return
            }
            
            XCTAssertEqual(isTyping.userIdentifier, "alice")
        }
    }
    
    func test_init_isTypingInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "is_typing",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"user_id\""])
    }
    
    // MARK: - Presence Subscription
    
    func test_init_presenceStateAllFieldsValid_noProblem() {
        
        let jsonData = """
        {
            "event_name": "presence_state",
            "data": {
                "state": "online"
            },
            "timestamp": "2017-03-23T11:36:42Z"
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.Event.Subscription(from: jsonData.jsonDecoder())) { subscription in
            XCTAssertEqual(subscription.eventName, .presenceState)
            XCTAssertEqual(subscription.timestamp, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            guard case let Wire.Event.EventType.presenceState(presenceState) = subscription.data else {
                XCTFail("Expected `data` value of .presenceState but got a different value instead: \(subscription.data)")
                return
            }
            
            XCTAssertEqual(presenceState, .online)
        }
    }
    
    func test_init_presenceStateInvalidFormat_throws() {
        
        let jsonData = """
        {
            "data": { },
            "event_name": "presence_state",
            "timestamp": "2017-04-14T14:00:42Z",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.Event.Subscription(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"data\"",
                                          "No value associated with key",
                                          "\"state\""])
    }
    
}
