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

    public init(id: Int, createdAt: String, updatedAt: String, name: String? = nil, customId: String? = nil, customData: [String: Any]?, rooms: [PCRoom] = [], app: App) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.customId = customId
        self.customData = customData
        self.rooms = rooms
        self.app = app
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
            completionHandler(nil, ServiceError.invalidJSONObjectAsData(roomObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: roomObject, options: []) else {
            completionHandler(nil, ServiceError.failedToJSONSerializeData(roomObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms"
        let generalRequest = GeneralRequest(method: HttpMethod.POST.rawValue, path: path, body: data)

        self.app.request(using: generalRequest) { result in
            guard let data = result.value else {
                completionHandler(nil, result.error!)
                return
            }

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
        }
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
            completionHandler(ServiceError.invalidJSONObjectAsData(userPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
            completionHandler(ServiceError.failedToJSONSerializeData(userPayload))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/users"
        let generalRequest = GeneralRequest(method: HttpMethod.PUT.rawValue, path: path, body: data)

        self.app.request(using: generalRequest) { result in

            // TODO: What is data here?

            guard let data = result.value else {
                completionHandler(result.error!)
                return
            }

            completionHandler(nil)
        }
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
        let generalRequest = GeneralRequest(method: HttpMethod.GET.rawValue, path: path)

        self.app.request(using: generalRequest) { result in
            guard let data = result.value else {
                completionHandler(nil, result.error!)
                return
            }

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
                    DefaultLogger.Logger.log(message: "Incomplete room payload in getRooms response: \(roomPayload)")
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
        }
    }


    public func getRoom(id: Int, withMessages: Int? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/rooms/\(id)"
        let generalRequest = GeneralRequest(method: HttpMethod.GET.rawValue, path: path)

        if withMessages != nil {
            let withMessagesQueryItem = URLQueryItem(name: "with_messages", value: String(withMessages!))

            if let queryItems = generalRequest.queryItems {
                generalRequest.queryItems = queryItems + [withMessagesQueryItem]
            } else {
                generalRequest.queryItems = [withMessagesQueryItem]
            }
        }

        self.app.request(using: generalRequest) { result in
            guard let data = result.value else {
                completionHandler(nil, result.error!)
                return
            }

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
                        DefaultLogger.Logger.log(message: "Incomplete message payload in getRoom call: \(messagePayload)")
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
                    DefaultLogger.Logger.log(message: "Incomplete membership payload in initial_state event for room: \(roomName)")
                    return nil
                }

                guard let userId = membershipUserPayload["id"] as? Int,
                      let createdAt = membershipUserPayload["created_at"] as? String,
                      let updatedAt = membershipUserPayload["updated_at"] as? String
                else {
                    // TODO: Log or complete with error here?
                    DefaultLogger.Logger.log(message: "Incomplete user payload in initial_state event for room: \(roomName)")
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
        }
    }



    // MARK: Message-related interactions

    public func addMessage(text: String, to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let messageObject: [String: Any] = [
            "text": text,
            "user_id": self.id
        ]

        guard JSONSerialization.isValidJSONObject(messageObject) else {
            completionHandler(ServiceError.invalidJSONObjectAsData(messageObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
            completionHandler(ServiceError.failedToJSONSerializeData(messageObject))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/messages"
        let generalRequest = GeneralRequest(method: HttpMethod.POST.rawValue, path: path, body: data)

        self.app.request(using: generalRequest) { result in

            // TODO: What is data here if we just get a 201 back and no body?

            guard let data = result.value else {
                completionHandler(result.error!)
                return
            }

            completionHandler(nil)
        }
    }


    // MARK: RoomSubscription

    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate? = nil, completionHandler: @escaping (Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/room/\(room.id)"

        var resumableSub = ResumableSubscription(
            app: self.app,
            path: path
            //            onOpening: onUserSubscriptionStateChange(),
            //            onOpen: onOpen,
            //            onResuming: onResuming,
            //            onEnd: onEnd,
            //            onError: onError
        )

        room.subscription = PCRoomSubscription(
            delegate: roomDelegate,
            resumableSubscription: resumableSub,
            completionHandler: completionHandler
        )
        
        let subscribeRequest = SubscribeRequest(path: path)
        
        self.app.subscribeWithResume(
            resumableSubscription: &resumableSub,
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
