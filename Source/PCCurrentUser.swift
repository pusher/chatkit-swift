import PusherPlatform

public class PCCurrentUser {
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customId: String?
    public let customData: [String: Any]?

    let userStore: PCUserStore
    let roomStore: PCRoomStore

    public var users: Set<PCUser> {
        get {
            return self.userStore.users
        }
    }

    public var rooms: [PCRoom] {
        get {
            return self.roomStore.rooms.underlyingArray
        }
    }

    var typingIndicatorManagers: [Int: PCTypingIndicatorManager] = [:]
    private var typingIndicatorQueue = DispatchQueue(label: "com.pusher.chat-api.typing-indicators")

    internal lazy var basicMessageEnricher: PCBasicMessageEnricher = {
        return PCBasicMessageEnricher(userStore: self.userStore, roomStore: self.roomStore, logger: self.app.logger)
    }()

    let app: App

    public init(
        id: Int,
        createdAt: String,
        updatedAt: String,
        name: String? = nil,
        customId: String? = nil,
        customData: [String: Any]?,
        rooms: PCSynchronizedArray<PCRoom> = PCSynchronizedArray<PCRoom>(),
        app: App,
        userStore: PCUserStore
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.customId = customId
        self.customData = customData
        self.roomStore = PCRoomStore(rooms: rooms, app: app)
        self.app = app
        self.userStore = userStore
    }

    public func createRoom(
        name: String,
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

        let path = "/\(ChatManager.namespace)/rooms"
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

//    public func createRoom(
//        name: String,
//        delegate: PCRoomDelegate? = nil,
//        addUsers users: [PCUser]? = nil,
//        completionHandler: @escaping (PCRoom?, Error?) -> Void
//    ) {
//        let userIdsToAdd = users?.flatMap { return $0.id }
//        self.createRoom(name: name, delegate: delegate, addUserIds: userIdsToAdd, completionHandler: completionHandler)
//    }

    // TODO: How to setup completion handlers when return payload is unclear - do we
    // just optionally return an error or do we return User(s) / Room?


    public func add(_ user: PCUser, to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.add([user], to: room, completionHandler: completionHandler)
    }

    public func add(_ users: [PCUser], to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let userIds = users.map { $0.id }
        self.add(userIds: userIds, to: room.id, completionHandler: completionHandler)
    }

    public func add(userIds: [Int], to roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        self.addOrRemoveUsers(in: roomId, userIds: userIds, membershipChange: .add, completionHandler: completionHandler)
    }

    public func remove(_ user: PCUser, from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.remove([user], from: room, completionHandler: completionHandler)
    }

    public func remove(_ users: [PCUser], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let userIds = users.map { $0.id }
        self.remove(userIds: userIds, from: room, completionHandler: completionHandler)
    }

    public func remove(userIds: [Int], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.addOrRemoveUsers(in: room.id, userIds: userIds, membershipChange: .remove, completionHandler: completionHandler)
    }

    fileprivate func addOrRemoveUsers(
        in roomId: Int,
        userIds: [Int],
        membershipChange: PCUserMembershipChange,
        completionHandler: @escaping (Error?) -> Void
    ) {
        let userPayload = ["\(membershipChange.rawValue)_user_ids": userIds]

        guard JSONSerialization.isValidJSONObject(userPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(userPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(userPayload))
            return
        }

        let path = "/\(ChatManager.namespace)/rooms/\(roomId)/users"
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
        self.add(userIds: [self.id], to: room.id, completionHandler: completionHandler)
    }

    public func join(roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        self.add(userIds: [self.id], to: roomId, completionHandler: completionHandler)
    }

    public func leave(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.remove(userIds: [self.id], from: room, completionHandler: completionHandler)
    }

    public func getRooms(completionHandler: @escaping ([PCRoom]?, Error?) -> Void) {
        let path = "/\(ChatManager.namespace)/rooms"
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
                        self.app.logger.log(err.localizedDescription, logLevel: .debug)
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
        roomId: Int,
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

        let path = "/\(ChatManager.namespace)/rooms/\(roomId)/events"
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

    public func typing(in room: PCRoom, timeoutAfter: TimeInterval = 3) {
        var typingIndicatorManager: PCTypingIndicatorManager!

        typingIndicatorQueue.sync {
            if let manager = self.typingIndicatorManagers[room.id] {
                typingIndicatorManager = manager
            } else {
                let manager = PCTypingIndicatorManager(typingTimeoutInterval: timeoutAfter, roomId: room.id, currentUser: self)
                self.typingIndicatorManagers[room.id] = manager
                typingIndicatorManager = manager
            }
        }

        typingIndicatorManager.typing()
    }

    func startedTypingIn(roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        let eventPayload: [String: Any] = ["name": "typing_start", "data": [:], "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: roomId, completionHandler: completionHandler)
    }

    func stoppedTypingIn(roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        let eventPayload: [String: Any] = ["name": "typing_stop", "data": [:], "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: roomId, completionHandler: completionHandler)
    }

    public func startedTypingIn(_ room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let eventPayload: [String: Any] = ["name": "typing_start", "data": [:], "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: room.id, completionHandler: completionHandler)
    }

    public func stoppedTypingIn(_ room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let eventPayload: [String: Any] = ["name": "typing_stop", "data": [:], "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: room.id, completionHandler: completionHandler)
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

        let path = "/\(ChatManager.namespace)/rooms/\(room.id)/messages"
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



    // TODO: Where should all the makeActiveRoom stuff live?

    public func makeActiveRoom(_ room: PCRoom, delegate: PCRoomDelegate) {
        self.subscribeToRoom(room: room, roomDelegate: delegate)
    }

    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate) {
        self.fetchMessagesFromRoom(room) { messages, err in
            guard err == nil else {
                roomDelegate.error(PCRoomSubscriptionError.failedToFetchInitialStateForRoomSubscription)
                return
            }

            let path = "/\(ChatManager.namespace)/rooms/\(room.id)"

            let subscribeRequest = PPRequestOptions(
                method: HTTPMethod.SUBSCRIBE.rawValue,
                path: path,
                queryItems: [URLQueryItem(name: "user_id", value: String(self.id))]
            )

            var resumableSub = PPResumableSubscription(
                app: self.app,
                requestOptions: subscribeRequest
            )

            if let firstMessage = messages!.first {
                self.app.logger.log("Subscribing to room \(room.name) and providing Last-Event-ID as \(firstMessage.id)", logLevel: .verbose)
                let mostRecentlyReceivedMessageId = String(firstMessage.id)
                subscribeRequest.addHeaders(["Last-Event-ID": mostRecentlyReceivedMessageId])
                resumableSub.setLastEventIdReceivedTo(mostRecentlyReceivedMessageId)
            }

            room.subscription = PCRoomSubscription(
                delegate: roomDelegate,
                resumableSubscription: resumableSub,
                logger: self.app.logger,
                basicMessageEnricher: self.basicMessageEnricher
            )

            messages?.reversed().forEach { message in
                self.app.logger.log("Calling newMessage function on room delegate for message with id \(message.id)", logLevel: .verbose)
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

    // This seems to only be used by subscribeToRoom

    public func fetchMessagesFromRoom(
        _ room: PCRoom,
        initialId: String? = nil,
        limit: Int? = nil,
        direction: PCRoomMessageFetchDirection = .older,
        completionHandler: @escaping ([PCMessage]?, Error?) -> Void
    ) {
        let path = "/\(ChatManager.namespace)/rooms/\(room.id)/messages"
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

                let progressCounter = PCMessageEnrichmentProgressCounter(totalCount: messagesPayload.count)
                let messages = PCSynchronizedArray<PCMessage>()

                messagesPayload.forEach { messagePayload in
                    do {
                        let basicMessage = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)

                        self.basicMessageEnricher.enrich(basicMessage) { message, err in
                            guard let message = message, err == nil else {
                                progressCounter.incrementFailed()
                                self.app.logger.log(err!.localizedDescription, logLevel: .debug)

                                if progressCounter.finished {
                                    completionHandler(messages.underlyingArray.sorted(by: { $0.0.id > $0.1.id }), nil)
                                }
                                return
                            }

                            messages.append(message)
                            progressCounter.incrementSuccess()

                            if progressCounter.finished {
                                completionHandler(messages.underlyingArray.sorted(by: { $0.0.id > $0.1.id }), nil)
                            }
                        }
                    } catch let err {
                        progressCounter.incrementFailed()
                        self.app.logger.log(err.localizedDescription, logLevel: .debug)

                        if progressCounter.finished {
                            completionHandler(messages.underlyingArray.sorted(by: { $0.0.id > $0.1.id }), nil)
                        }
                    }
                }
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

}

public enum PCRoomMessageFetchDirection: String {
    case older
    case newer
}
