import PusherPlatform

public class PCCurrentUser {
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customId: String?
    public let customData: [String: Any]?
    public internal(set) var rooms: PCSynchronizedArray<PCRoom>

    fileprivate let app: App
    public let logger: PPLogger

    public init(
        id: Int,
        createdAt: String,
        updatedAt: String,
        name: String? = nil,
        customId: String? = nil,
        customData: [String: Any]?,
        rooms: PCSynchronizedArray<PCRoom> = PCSynchronizedArray<PCRoom>(),
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

                // TODO: Does added_to_room get triggered?

                completionHandler(room, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    // TODO: How to make unambiguous if you just want to pass in a name for the room?

//    public func createRoom(name
//        : String, delegate: PCRoomDelegate? = nil, addUsers users: [PCUser]? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
//        let userIdsToAdd = users?.flatMap { return $0.id }
//        self.createRoom(name: name, delegate: delegate, addUserIds: userIdsToAdd, completionHandler: completionHandler)
//    }

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

                    messagesPayload.forEach { messagePayload in
                        guard let messageId = messagePayload["id"] as? Int,
                              let messageSenderId = messagePayload["user_id"] as? Int,
                              let messageRoomId = messagePayload["room_id"] as? Int,
                              let messageText = messagePayload["text"] as? String,
                              let messageCreatedAt = messagePayload["created_at"] as? String,
                              let messageUpdatedAt = messagePayload["updated_at"] as? String
                        else {
                            self.logger.log("Incomplete message payload in getRoom call: \(messagePayload)", logLevel: .debug)
                            return
                        }

                        room.messages.append(PCMessage(
                            id: messageId,
                            senderId: messageSenderId,
                            roomId: messageRoomId,
                            text: messageText,
                            createdAt: messageCreatedAt,
                            updatedAt: messageUpdatedAt
                        ))
                    }
                }

                memberships.forEach { membership in
                    guard let membershipUserPayload = membership["user"] as? [String: Any] else {
                        self.logger.log("Incomplete membership payload in initial_state event for room: \(roomName)", logLevel: .debug)
                        return
                    }

                    guard let userId = membershipUserPayload["id"] as? Int,
                          let createdAt = membershipUserPayload["created_at"] as? String,
                          let updatedAt = membershipUserPayload["updated_at"] as? String
                    else {
                        // TODO: Log or complete with error here?
                        self.logger.log("Incomplete user payload in initial_state event for room: \(roomName)", logLevel: .debug)
                        return
                    }

                    room.users.append(PCUser(
                        id: userId,
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        name: membershipUserPayload["name"] as? String,
                        customId: membershipUserPayload["custom_id"] as? String,
                        customData: membershipUserPayload["custom_data"] as? [String: Any]
                    ))
                }

                completionHandler(room, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }



    // MARK: Message-related interactions

    // TODO: Should we add the message to the room in the onSuccess here, as long as we
    // get the message id back from the server?

    public func addMessage(text: String, to room: PCRoom, completionHandler: @escaping (Int?, Error?) -> Void) {
        let messageObject: [String: Any] = [
            "text": text,
            "user_id": self.id
        ]

        guard JSONSerialization.isValidJSONObject(messageObject) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(messageObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(messageObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let messageIdPayload = jsonObject as? [String: Int] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                guard let messageId = messageIdPayload["message_id"] else {
                    completionHandler(nil, PCError.messageIdKeyMissingInMessageCreationResponse(messageIdPayload))
                    return
                }

                completionHandler(messageId, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    public func fetchMessagesFromRoom(
        _ room: PCRoom,
        initialId: String? = nil,
        limit: Int? = nil,
        direction: PCRoomMessageFetchDirection = .older,
        completionHandler: @escaping ([PCMessage]?, Error?) -> Void
    ) {
        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        if let initialId = initialId {
            generalRequest.addQueryItems([URLQueryItem(name: "initial_id", value: initialId)])
        }

        if let limit = limit {
            generalRequest.addQueryItems([URLQueryItem(name: "limit", value: String(limit))])
        }

        generalRequest.addQueryItems([URLQueryItem(name: "direction", value: direction.rawValue)])

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let messagesPayload = jsonObject as? [[String: Any]] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
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

                completionHandler(messages, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }


    // MARK: PCRoomSubscription

    // TODO: What do we return here?

    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate) {
        self.fetchMessagesFromRoom(room) { messages, err in
            guard err == nil else {
                roomDelegate.error(PCRoomSubscriptionError.failedToFetchInitialStateForRoomSubscription)
                return
            }

            let path = "/\(ChatAPI.namespace)/rooms/\(room.id)"

            let subscribeRequest = PPRequestOptions(
                method: HTTPMethod.SUBSCRIBE.rawValue,
                path: path,
                queryItems: [URLQueryItem(name: "user_id", value: String(self.id))]
            )

            if let firstMessage = messages!.first {
                subscribeRequest.addHeaders(["Last-Event-ID": String(firstMessage.id)])
            }

            var resumableSub = PPResumableSubscription(
                app: self.app,
                requestOptions: subscribeRequest
            )

            room.subscription = PCRoomSubscription(
                delegate: roomDelegate,
                resumableSubscription: resumableSub,
                logger: self.app.logger
            )

            messages?.reversed().forEach { message in
                roomDelegate.newMessage(message)
            }

            self.app.subscribeWithResume(
                with: &resumableSub,
                using: subscribeRequest,
                onEvent: room.subscription?.handleEvent

                // TODO: This will probably be replaced by the state change delegate function, with an associated type, maybe

//                onError: { error in
//                    roomDelegate.receivedError(error)
//                }
            )

        }
    }
}

public enum PCRoomMessageFetchDirection: String {
    case older
    case newer
}
