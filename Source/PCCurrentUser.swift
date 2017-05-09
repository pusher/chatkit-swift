import PusherPlatform

public class PCCurrentUser {
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customId: String?
    public let customData: [String: Any]?
    public internal(set) var rooms: [PCRoom]

    fileprivate let app: App
    public let logger: PPLogger

    public init(
        id: Int,
        createdAt: String,
        updatedAt: String,
        name: String? = nil,
        customId: String? = nil,
        customData: [String: Any]?,
        rooms: [PCRoom] = [],
        app: App
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.customId = customId
        self.customData = customData
        self.rooms = rooms
        self.app = app
        self.logger = app.logger
    }

    public func createRoom(name: String, delegate: PCRoomDelegate? = nil, addUserIds userIds: [Int]? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        var roomObject: [String: Any] = [
            "name": name,
            "created_by_id": self.id
        ]

        // TODO: This is a bit gross

        if userIds != nil && userIds!.count > 0 {
            roomObject["user_ids"] = userIds
        }

        guard JSONSerialization.isValidJSONObject(roomObject) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(roomObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: roomObject, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(roomObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let roomPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                guard let roomId = roomPayload["id"] as? Int,
                      let roomName = roomPayload["name"] as? String,
                      let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
                      let roomCreatedAt = roomPayload["created_at"] as? String,
                      let roomUpdatedAt = roomPayload["updated_at"] as? String
                else {
                    completionHandler(nil, PCError.roomCreationResponsePayloadIncomplete(roomPayload))
                    return
                }

                let room = PCRoom(
                    id: roomId,
                    name: roomName,
                    createdByUserId: roomCreatorUserId,
                    createdAt: roomCreatedAt,
                    updatedAt: roomUpdatedAt
                )

                self.rooms.append(room)
                completionHandler(room, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    public func createRoom(name: String, delegate: PCRoomDelegate? = nil, addUsers users: [PCUser]? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        let userIdsToAdd = users?.flatMap { return $0.id }
        self.createRoom(name: name, delegate: delegate, addUserIds: userIdsToAdd, completionHandler: completionHandler)
    }

    // TODO: How to setup completion handlers when return payload is unclear - do we
    // just optionally return an error or do we return User(s) / Room?

    // MARK: Room-related interactions

    public func add(_ user: PCUser, to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.add([user], to: room, completionHandler: completionHandler)
    }

    public func add(_ users: [PCUser], to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let userIds = users.map { $0.id }
        self.add(userIds: userIds, to: room, completionHandler: completionHandler)
    }

    public func add(userIds: [Int], to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.addOrRemoveUsers(in: room, userIds: userIds, membershipChange: .add, completionHandler: completionHandler)
    }

    public func remove(_ user: PCUser, from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.remove([user], from: room, completionHandler: completionHandler)
    }

    public func remove(_ users: [PCUser], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let userIds = users.map { $0.id }
        self.remove(userIds: userIds, from: room, completionHandler: completionHandler)
    }

    public func remove(userIds: [Int], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.addOrRemoveUsers(in: room, userIds: userIds, membershipChange: .remove, completionHandler: completionHandler)
    }

    fileprivate func addOrRemoveUsers(in room: PCRoom, userIds: [Int], membershipChange: PCUserMembershipChange, completionHandler: @escaping (Error?) -> Void) {
        let userPayload = ["\(membershipChange.rawValue)_user_ids": userIds]

        guard JSONSerialization.isValidJSONObject(userPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(userPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(userPayload))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/users"
        let generalRequest = PPRequestOptions(method: HTTPMethod.PUT.rawValue, path: path, body: data)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                // TODO: What is data here?

                completionHandler(nil)
            },
            onError: { error in
                completionHandler(error)
            }
        )
    }

    fileprivate enum PCUserMembershipChange: String {
        case add
        case remove
    }

    public func join(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.add(userIds: [self.id], to: room, completionHandler: completionHandler)
    }

    public func leave(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.remove(userIds: [self.id], from: room, completionHandler: completionHandler)
    }

    public func getRooms(completionHandler: @escaping ([PCRoom]?, Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/rooms"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let roomsPayload = jsonObject as? [[String: Any]] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                let rooms = roomsPayload.flatMap { roomPayload -> PCRoom? in
                    guard let roomId = roomPayload["id"] as? Int,
                         let roomName = roomPayload["name"] as? String,
                         let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
                         let roomCreatedAt = roomPayload["created_at"] as? String,
                         let roomUpdatedAt = roomPayload["updated_at"] as? String
                    else {
                        self.logger.log("Incomplete room payload in getRooms response: \(roomPayload)", logLevel: .debug)
                        return nil
                    }

                    return PCRoom(
                        id: roomId,
                        name: roomName,
                        createdByUserId: roomCreatorUserId,
                        createdAt: roomCreatedAt,
                        updatedAt: roomUpdatedAt
                    )
                }

                completionHandler(rooms, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }


    public func getRoom(id: Int, withMessages: Int? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/rooms/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        if withMessages != nil {
            let withMessagesQueryItem = URLQueryItem(name: "with_messages", value: String(withMessages!))
            generalRequest.addQueryItems([withMessagesQueryItem])
        }

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let roomPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                guard let roomId = roomPayload["id"] as? Int,
                    let roomName = roomPayload["name"] as? String,
                    let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
                    let roomCreatedAt = roomPayload["created_at"] as? String,
                    let roomUpdatedAt = roomPayload["updated_at"] as? String,
                    let memberships = roomPayload["memberships"] as? [[String: Any]]
                    else {
                        completionHandler(nil, PCError.incompleteRoomPayloadInGetRoomResponse(roomPayload))
                        return
                }

                let room = PCRoom(
                    id: roomId,
                    name: roomName,
                    createdByUserId: roomCreatorUserId,
                    createdAt: roomCreatedAt,
                    updatedAt: roomUpdatedAt
                )

                if withMessages != nil {
                    guard let messagesPayload = roomPayload["messages"] as? [[String: Any]] else {
                        completionHandler(nil, PCError.incompleteRoomPayloadInGetRoomResponse(roomPayload))
                        return
                    }

                    let messages = messagesPayload.flatMap { messagePayload -> PCMessage? in
                        guard let messageId = messagePayload["id"] as? Int,
                              let messageSenderId = messagePayload["user_id"] as? Int,
                              let messageRoomId = messagePayload["room_id"] as? Int,
                              let messageText = messagePayload["text"] as? String,
                              let messageCreatedAt = messagePayload["created_at"] as? String,
                              let messageUpdatedAt = messagePayload["updated_at"] as? String
                        else {
                            self.logger.log("Incomplete message payload in getRoom call: \(messagePayload)", logLevel: .debug)
                            return nil
                        }

                        return PCMessage(
                            id: messageId,
                            senderId: messageSenderId,
                            roomId: messageRoomId,
                            text: messageText,
                            createdAt: messageCreatedAt,
                            updatedAt: messageUpdatedAt
                        )
                    }

                    room.messages = messages
                }

                let users = memberships.flatMap { membership -> PCUser? in
                    guard let membershipUserPayload = membership["user"] as? [String: Any] else {
                        self.logger.log("Incomplete membership payload in initial_state event for room: \(roomName)", logLevel: .debug)
                        return nil
                    }



                    guard let userId = membershipUserPayload["id"] as? Int,
                          let createdAt = membershipUserPayload["created_at"] as? String,
                          let updatedAt = membershipUserPayload["updated_at"] as? String
                    else {
                        // TODO: Log or complete with error here?
                        self.logger.log("Incomplete user payload in initial_state event for room: \(roomName)", logLevel: .debug)
                        return nil
                    }

                    return PCUser(
                        id: userId,
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        name: membershipUserPayload["name"] as? String,
                        customId: membershipUserPayload["custom_id"] as? String,
                        customData: membershipUserPayload["custom_data"] as? [String: Any]
                    )
                }

                room.users = users

                completionHandler(room, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }



    // MARK: Message-related interactions

    public func addMessage(text: String, to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let messageObject: [String: Any] = [
            "text": text,
            "user_id": self.id
        ]

        guard JSONSerialization.isValidJSONObject(messageObject) else {
            completionHandler(PCError.invalidJSONObjectAsData(messageObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(messageObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                // TODO: What is data here if we just get a 201 back and no body?
                completionHandler(nil)
            },
            onError: { error in
                completionHandler(error)
            }
        )
    }


    // MARK: RoomSubscription

    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate? = nil, completionHandler: @escaping (Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/room/\(room.id)"

        let subscribeRequest = PPRequestOptions(method: "SUBSCRIBE", path: path)

        var resumableSub = PPResumableSubscription(
            app: self.app,
            requestOptions: subscribeRequest
        )

        room.subscription = PCRoomSubscription(
            delegate: roomDelegate,
            resumableSubscription: resumableSub,
            completionHandler: completionHandler
        )

        self.app.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            //            onOpening: onOpening,
            //            onOpen: completionHandler,
            //            onResuming: onResuming,
            onEvent: room.subscription?.handleEvent,
            onEnd: { statusCode, headers, info in
                print("ENDED")
            },
            onError: { error in
                completionHandler(error)
            }
        )
    }
}
