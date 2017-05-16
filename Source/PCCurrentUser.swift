import PusherPlatform

public class PCCurrentUser {
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customId: String?
    public let customData: [String: Any]?

    public internal(set) var rooms: PCSynchronizedArray<PCRoom>
    public internal(set) var users: Set<PCUser> = []

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

    public func createRoom(
        name: String,
        delegate: PCRoomDelegate? = nil,
        addUserIds userIds: [Int]? = nil,
        completionHandler: @escaping (PCRoom?, Error?) -> Void
    ) {
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

                do {
                    let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

                    // TODO: Does added_to_room get triggered?
                    completionHandler(room, nil)
                } catch let err {
                    completionHandler(nil, err)
                }
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

    internal func findOrGetRoom(id: Int, completionHander: @escaping (PCRoom?, Error?) -> Void) {
        if let room = self.rooms.first(where: { $0.id == id }) {
            completionHander(room, nil)
        } else {
            self.getRoom(id: id) { room, err in
                guard err == nil else {
                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHander(nil, err!)
                    return
                }

                // TODO: Should the room be added to the currentUser?

                completionHander(room!, nil)
            }
        }
    }

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

    public func getRoom(id: Int, withMessages: Int? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/rooms/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        if let withMessages = withMessages {
            let withMessagesQueryItem = URLQueryItem(name: "with_messages", value: String(withMessages))
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

                let room: PCRoom

                do {
                    room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
                } catch let err {
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }

                if withMessages != nil {
                    guard let messagesPayload = roomPayload["messages"] as? [[String: Any]] else {
                        completionHandler(nil, PCError.incompleteRoomPayloadInGetRoomResponse(roomPayload))
                        return
                    }

                    messagesPayload.forEach { messagePayload in
                        do {
                            let message = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)
                            room.messages.append(message)
                        } catch let err {
                            self.app.logger.log(err.localizedDescription, logLevel: .debug)
                            completionHandler(nil, err)
                            return
                        }
                    }
                }

                completionHandler(room, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
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
                    do {
                        return try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
                    } catch let err {
                        self.logger.log(err.localizedDescription, logLevel: .debug)
                        return nil
                    }
                }

                completionHandler(rooms, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    fileprivate func typingStateChange(
        eventPayload: [String: Any],
        room: PCRoom,
        completionHandler: @escaping (Error?) -> Void
    ) {
        guard JSONSerialization.isValidJSONObject(eventPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(eventPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: eventPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(eventPayload))
            return
        }

        let path = "/\(ChatAPI.namespace)/rooms/\(room.id)/events"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

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

    public func startedTypingIn(_ room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let eventPayload: [String: Any] = ["name": "typing_start", "data": [:], "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, room: room, completionHandler: completionHandler)
    }

    // TODO: Add version of startedTyping that auto-calls stoppedTyping after timeout period, unless
    // some sort of update event is triggered locally in the SDK

    public func stoppedTypingIn(_ room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let eventPayload: [String: Any] = ["name": "typing_stop", "data": [:], "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, room: room, completionHandler: completionHandler)
    }

    // MARK: User-related interactions

    internal func findOrGetUser(id: Int, completionHander: @escaping (PCUser?, Error?) -> Void) {
        if let user = self.users.first(where: { $0.id == id }) {
            completionHander(user, nil)
        } else {
            self.getUser(id: id) { user, err in
                guard err == nil else {
                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHander(nil, err!)
                    return
                }

                // TODO: Should the user be added to the currentUser?

                completionHander(user!, nil)
            }
        }
    }

    public func getUser(id: Int, completionHandler: @escaping (PCUser?, Error?) -> Void) {
        let path = "/\(ChatAPI.namespace)/users/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.app.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let userPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                do {
                    let user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
                    completionHandler(user, nil)
                } catch let err {
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }
            },
            onError: { err in
                completionHandler(nil, err)
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
                    do {
                        return try PCPayloadDeserializer.createMessageFromPayload(messagePayload)
                    } catch let err {
                        self.logger.log(err.localizedDescription, logLevel: .debug)
                        return nil
                    }
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
