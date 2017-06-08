import Foundation
import PusherPlatform

public class PCCurrentUser {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customData: [String: Any]?

    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore

    // TODO: This should probably be [PCUser] instead, like the users property
    // in PCRoom, or something even simpler
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

    public let pathFriendlyId: String

    public internal(set) var presenceSubscription: PCPresenceSubscription? = nil

    var typingIndicatorManagers: [Int: PCTypingIndicatorManager] = [:]
    private var typingIndicatorQueue = DispatchQueue(label: "com.pusher.chat-api.typing-indicators")

    let app: App

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        name: String? = nil,
        customData: [String: Any]?,
        rooms: PCSynchronizedArray<PCRoom> = PCSynchronizedArray<PCRoom>(),
        app: App,
        userStore: PCGlobalUserStore
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.customData = customData
        self.roomStore = PCRoomStore(rooms: rooms, app: app)
        self.app = app
        self.userStore = userStore

        let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted

        // TODO: When can percent encoding fail?
        self.pathFriendlyId = id.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? id
    }

    func setupPresenceSubscription(delegate: PCChatManagerDelegate) {
        let path = "/\(ChatManager.namespace)/users/\(self.id)/presence"

        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)

        var resumableSub = PPResumableSubscription(
            app: self.app,
            requestOptions: subscribeRequest
        )

        self.presenceSubscription = PCPresenceSubscription(
            app: self.app,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            roomStore: self.roomStore,
            delegate: delegate
        )

        self.app.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: self.presenceSubscription!.handleEvent
        )
    }

    public func createRoom(
        name: String,
        isPrivate: Bool = true,
        addUserIds userIds: [String]? = nil,
        completionHandler: @escaping (PCRoom?, Error?) -> Void
    ) {
        var roomObject: [String: Any] = [
            "name": name,
            "created_by_id": self.id,
            "private": isPrivate
        ]

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

                    // TODO: Would it be better if we instead relied on `added_to_room` event?
                    // TODO: Use the soon-to-be-created new version of fetchUsersWithIds from the 
                    // userStore

                    self.roomStore.add(room) {
                        completionHandler(room, nil)
                    }

                    let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIds.count, labelSuffix: "room-users")

                    room.userIds.forEach { userId in
                        self.userStore.user(id: userId) { user, err in
                            guard let user = user, err == nil else {
                                self.app.logger.log(
                                    "Unable to add user with id \(userId) to room \(room.name): \(err!.localizedDescription)",
                                    logLevel: .debug
                                )

                                if roomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                                    room.subscription?.delegate?.usersUpdated()
                                }

                                return
                            }

                            room.userStore.addOrMerge(user)

                            if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                                room.subscription?.delegate?.usersUpdated()
                            }
                        }
                    }
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


    // MARK: Room membership-related interactions

    public func add(_ user: PCUser, to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.add([user], to: room, completionHandler: completionHandler)
    }

    public func add(_ users: [PCUser], to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let userIds = users.map { $0.id }
        self.add(userIds: userIds, to: room.id, completionHandler: completionHandler)
    }

    public func add(userIds: [String], to roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        self.addOrRemoveUsers(in: roomId, userIds: userIds, membershipChange: .add, completionHandler: completionHandler)
    }

    public func remove(_ user: PCUser, from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.remove([user], from: room, completionHandler: completionHandler)
    }

    public func remove(_ users: [PCUser], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        let userIds = users.map { $0.id }
        self.remove(userIds: userIds, from: room, completionHandler: completionHandler)
    }

    public func remove(userIds: [String], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.addOrRemoveUsers(in: room.id, userIds: userIds, membershipChange: .remove, completionHandler: completionHandler)
    }

    fileprivate func addOrRemoveUsers(
        in roomId: Int,
        userIds: [String],
        membershipChange: PCUserMembershipChange,
        completionHandler: @escaping (Error?) -> Void
    ) {
        let userPayload = ["user_ids": userIds]

        guard JSONSerialization.isValidJSONObject(userPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(userPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(userPayload))
            return
        }

        let path = "/\(ChatManager.namespace)/rooms/\(roomId)/users/\(membershipChange.rawValue)"
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

    fileprivate enum PCCurrentUserMembershipChange: String {
        case join
        case leave
    }

    fileprivate func joinOrLeaveRoom(
        roomId: Int,
        membershipChange: PCCurrentUserMembershipChange,
        completionHandler: @escaping (Error?) -> Void
    ) {
        let path = "/\(ChatManager.namespace)/users/\(self.pathFriendlyId)/rooms/\(roomId)/\(membershipChange.rawValue)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path)

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

    public func join(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.joinOrLeaveRoom(roomId: room.id, membershipChange: .join, completionHandler: completionHandler)
    }

    public func join(roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        self.joinOrLeaveRoom(roomId: roomId, membershipChange: .join, completionHandler: completionHandler)
    }

    public func leave(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
        self.joinOrLeaveRoom(roomId: room.id, membershipChange: .leave, completionHandler: completionHandler)
    }

    public func leave(roomId: Int, completionHandler: @escaping (Error?) -> Void) {
        self.joinOrLeaveRoom(roomId: roomId, membershipChange: .leave, completionHandler: completionHandler)
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
                        // TODO: Do we need to fetch users in the room here?
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

    // MARK: Typing-indicator-related interactions

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
                    completionHandler(nil, PCMessageError.messageIdKeyMissingInMessageCreationResponse(messageIdPayload))
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

    // TODO: Do I need to add a Last-Event-ID option here?
    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate, messageLimit: Int = 20) {
        let path = "/\(ChatManager.namespace)/rooms/\(room.id)"

        // TODO: What happens if you provide both a message_limit and a Last-Event-ID?
        let subscribeRequest = PPRequestOptions(
            method: HTTPMethod.SUBSCRIBE.rawValue,
            path: path,
            queryItems: [
                URLQueryItem(name: "user_id", value: self.id),
                URLQueryItem(name: "message_limit", value: String(messageLimit))
            ]
        )

        var resumableSub = PPResumableSubscription(
            app: self.app,
            requestOptions: subscribeRequest
        )

        room.subscription = PCRoomSubscription(
            delegate: roomDelegate,
            resumableSubscription: resumableSub,
            logger: self.app.logger,
            basicMessageEnricher: PCBasicMessageEnricher(userStore: self.userStore, room: room, logger: self.app.logger)
        )

        self.app.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: room.subscription?.handleEvent

            // TODO: This will probably be replaced by the state change delegate function, with an associated type, maybe
//            onError: { error in
//                roomDelegate.receivedError(error)
//            }
        )
    }

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

                let progressCounter = PCProgressCounter(totalCount: messagesPayload.count, labelSuffix: "message-encricher")
                let messages = PCSynchronizedArray<PCMessage>()
                var basicMessages: [PCBasicMessage] = []

                let messageUserIds = messagesPayload.flatMap { messagePayload -> String? in
                    do {
                        let basicMessage = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)
                        basicMessages.append(basicMessage)
                        return basicMessage.senderId
                    } catch let err {
                        self.app.logger.log(err.localizedDescription, logLevel: .debug)
                        return nil
                    }
                }

                self.userStore.fetchUsersWithIds(messageUserIds) { _, err in
                    if let err = err {
                        self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    }

                    let messageEnricher = PCBasicMessageEnricher(
                        userStore: self.userStore,
                        room: room,
                        logger: self.app.logger
                    )

                    basicMessages.forEach { basicMessage in
                        messageEnricher.enrich(basicMessage) { message, err in
                            guard let message = message, err == nil else {
                                self.app.logger.log(err!.localizedDescription, logLevel: .debug)

                                if progressCounter.incrementFailedAndCheckIfFinished() {
                                    completionHandler(messages.underlyingArray.sorted(by: { $0.0.id > $0.1.id }), nil)
                                }

                                return
                            }

                            messages.append(message)
                            if progressCounter.incrementSuccessAndCheckIfFinished() {
                                completionHandler(messages.underlyingArray.sorted(by: { $0.0.id > $0.1.id }), nil)
                            }
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

public enum PCMessageError: Error {
    case messageIdKeyMissingInMessageCreationResponse([String: Int])
}

extension PCMessageError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .messageIdKeyMissingInMessageCreationResponse(let payload):
            return "\"message_id\" key missing from response after message creation: \(payload)"
        }
    }

}

public enum PCRoomMessageFetchDirection: String {
    case older
    case newer
}
