//import PusherPlatform
//
//@objc public class PCChatManager: NSObject {
//    static public let namespace = "chat_api/v1"
//
//    public let app: App
//
////    public internal(set) var userRoomsSubscription: PCUserRoomsSubscription? = nil
//
//    public var currentUser: PCCurrentUser? = nil
//
//    // TODO: Nil-able?
//    public var delegate: PCChatManagerDelegate? = nil
//
//    // TODO: _remove_ userId should just be inferred from user token
//    public var userId: Int
//
//    public internal(set) var users: Set<PCUser> = []
//
//    //    public internal(set) var userPresenceSubscription: PCUserPresenceSubscription? = nil
//
//
//
//    // TODO: Remove legacy
//
//    public internal(set) var userSubscription: PCUserSubscription? = nil
//
//
//
//    public init(
//        id: String,
//        app: App? = nil,
//        authorizer: PPAuthorizer? = nil,
//        logger: PPLogger? = nil,
//        baseClient: PPBaseClient? = nil,
//        userId: Int
//    ) {
//        self.app = app ?? App(id: id, authorizer: authorizer, client: baseClient, logger: logger)
//        self.userId = userId
//    }
//
//    public struct PCConnectInitialState {
//        public let currentUser: PCCurrentUser
//        public let rooms: PCSynchronizedArray<PCRoom>
//    }
//
//    public func connect(userId: Int, delegate: PCUserSubscriptionDelegate, completionHandler: @escaping (PCCurrentUser?, Error?) -> Void) {
//        self.userId = userId
//        let path = "/\(PCChatManager.namespace)/users/\(userId)"
//
//        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)
//
//        // TODO: Should be a PPRetryableSubscription
//
//        var resumableSub = PPResumableSubscription(
//            app: self.app,
//            requestOptions: subscribeRequest
//        )
//
//        self.userSubscription = PCUserSubscription(
//            app: self.app,
//            resumableSubscription: resumableSub,
//            delegate: delegate,
//            connectCompletionHandler: { user, error in
//                guard let cUser = user else {
//                    completionHandler(nil, error)
//                    return
//                }
//
//                completionHandler(cUser, nil)
//            }
//        )
//
//        // TODO: Fix this stuff
//
//        self.app.subscribeWithResume(
//            with: &resumableSub,
//            using: subscribeRequest,
//            //            onOpening: onOpening,
//            //            onOpen: onOpen,
//            //            onResuming: onResuming,
//            onEvent: self.userSubscription!.handleEvent,
//            onEnd: { statusCode, headers, info in
//                print("ENDED")
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//
////    public func connect(userId: Int, delegate: PCChatManagerDelegate) {
////        self.userId = userId
////        let path = "/\(PCChatManager.namespace)/users/\(userId)"
////
////        let subscribeRequest = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: path)
////
////        // TODO: Should be a PPRetryableSubscription
////
////        var resumableSub = PPResumableSubscription(
////            app: self.app,
////            requestOptions: subscribeRequest
////        )
////
////        self.userSubscription = PCUserSubscription(
////            app: self.app,
////            resumableSubscription: resumableSub,
////            delegate: delegate,
////            connectCompletionHandler: { user, error in
////                guard let cUser = user else {
////                    completionHandler(nil, error)
////                    return
////                }
////
////                completionHandler(cUser, nil)
////            }
////        )
////
////        // TODO: Fix this stuff
////
////        self.app.subscribeWithResume(
////            with: &resumableSub,
////            using: subscribeRequest,
////            //            onOpening: onOpening,
////            //            onOpen: onOpen,
////            //            onResuming: onResuming,
////            onEvent: self.userSubscription!.handleEvent,
////            onEnd: { statusCode, headers, info in
////                print("ENDED")
////        },
////            onError: { error in
////                completionHandler(nil, error)
////        }
////        )
////    }
//
//    // TODO: Is this legit?
//
//    public func makeRoomActive(_ room: PCRoom, delegate: PCRoomDelegate) {
//        self.subscribeToRoom(room: room, roomDelegate: delegate)
//    }
//
//    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate) {
//        self.fetchMessagesFromRoom(room) { messages, err in
//            guard err == nil else {
//                roomDelegate.error(PCRoomSubscriptionError.failedToFetchInitialStateForRoomSubscription)
//                return
//            }
//
//            let path = "/\(PCChatManager.namespace)/rooms/\(room.id)"
//
//            let subscribeRequest = PPRequestOptions(
//                method: HTTPMethod.SUBSCRIBE.rawValue,
//                path: path,
//                queryItems: [URLQueryItem(name: "user_id", value: String(self.userId))]
//            )
//
//            if let firstMessage = messages!.first {
//                subscribeRequest.addHeaders(["Last-Event-ID": String(firstMessage.id)])
//            }
//
//            var resumableSub = PPResumableSubscription(
//                app: self.app,
//                requestOptions: subscribeRequest
//            )
//
//            room.subscription = PCRoomSubscription(
//                delegate: roomDelegate,
//                resumableSubscription: resumableSub,
//                logger: self.app.logger
//            )
//
//            messages?.reversed().forEach { message in
//                roomDelegate.newMessage(message)
//            }
//
//            self.app.subscribeWithResume(
//                with: &resumableSub,
//                using: subscribeRequest,
//                onEvent: room.subscription?.handleEvent
//
//                // TODO: This will probably be replaced by the state change delegate function, with an associated type, maybe
////                onError: { error in
////                    roomDelegate.receivedError(error)
////                }
//            )
//
//        }
//    }
//
//    // This seems to only be used by subscribeToRoom
//
//    public func fetchMessagesFromRoom(
//        _ room: PCRoom,
//        initialId: String? = nil,
//        limit: Int? = nil,
//        direction: PCRoomMessageFetchDirection = .older,
//        completionHandler: @escaping ([PCMessage]?, Error?) -> Void
//    ) {
//        let path = "/\(PCChatManager.namespace)/rooms/\(room.id)/messages"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)
//
//        if let initialId = initialId {
//            generalRequest.addQueryItems([URLQueryItem(name: "initial_id", value: initialId)])
//        }
//
//        if let limit = limit {
//            generalRequest.addQueryItems([URLQueryItem(name: "limit", value: String(limit))])
//        }
//
//        generalRequest.addQueryItems([URLQueryItem(name: "direction", value: direction.rawValue)])
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let messagesPayload = jsonObject as? [[String: Any]] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                let messages = messagesPayload.flatMap { messagePayload -> PCMessage? in
//                    do {
//                        return try PCPayloadDeserializer.createMessageFromPayload(messagePayload)
//                    } catch let err {
//                        self.app.logger.log(err.localizedDescription, logLevel: .debug)
//                        return nil
//                    }
//                }
//
//                completionHandler(messages, nil)
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//
//    public enum PCRoomMessageFetchDirection: String {
//        case older
//        case newer
//    }
//
//}
//
//// MARK: User creation
//
//extension PCChatManager {
//    // TODO: Should a user creation function be available in the Swift lib?
//
//    public func createUser(name: String, completionHandler: @escaping (Int?, Error?) -> Void) {
//        let randomString = NSUUID().uuidString
//
//        let userObject: [String: Any] = ["name": name, "id": randomString]
//
//        guard JSONSerialization.isValidJSONObject(userObject) else {
//            completionHandler(nil, PCError.invalidJSONObjectAsData(userObject))
//            return
//        }
//
//        guard let data = try? JSONSerialization.data(withJSONObject: userObject, options: []) else {
//            completionHandler(nil, PCError.failedToJSONSerializeData(userObject))
//            return
//        }
//
//        let path = "/\(PCChatManager.namespace)/users"
//
//        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let json = jsonObject as? [String: Any] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                guard let id = json["id"] as? Int else {
//                    completionHandler(nil, PCError.userIdNotFoundInResponseJSON(json))
//                    return
//                }
//
//                completionHandler(id, nil)
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//}
//
//// MARK: Room creation
//
//extension PCChatManager {
//
//    public func createRoom(
//        name: String,
//        addUserIds userIds: [Int]? = nil,
//        completionHandler: @escaping (PCRoom?, Error?) -> Void
//    ) {
//        var roomObject: [String: Any] = [
//            "name": name,
//            "created_by_id": self.userId
//        ]
//
//        // TODO: This is a bit gross
//
//        if userIds != nil && userIds!.count > 0 {
//            roomObject["user_ids"] = userIds
//        }
//
//        guard JSONSerialization.isValidJSONObject(roomObject) else {
//            completionHandler(nil, PCError.invalidJSONObjectAsData(roomObject))
//            return
//        }
//
//        guard let data = try? JSONSerialization.data(withJSONObject: roomObject, options: []) else {
//            completionHandler(nil, PCError.failedToJSONSerializeData(roomObject))
//            return
//        }
//
//        let path = "/\(PCChatManager.namespace)/rooms"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let roomPayload = jsonObject as? [String: Any] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                do {
//                    let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
//
//                    // TODO: Does added_to_room get triggered?
//                    completionHandler(room, nil)
//                } catch let err {
//                    completionHandler(nil, err)
//                }
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//
//}
//
//// MARK: Message creation
//
//extension PCChatManager {
//
//    public func addMessage(text: String, to room: PCRoom, completionHandler: @escaping (Int?, Error?) -> Void) {
//        let messageObject: [String: Any] = [
//            "text": text,
//            "user_id": self.userId
//        ]
//
//        guard JSONSerialization.isValidJSONObject(messageObject) else {
//            completionHandler(nil, PCError.invalidJSONObjectAsData(messageObject))
//            return
//        }
//
//        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
//            completionHandler(nil, PCError.failedToJSONSerializeData(messageObject))
//            return
//        }
//
//        let path = "/\(PCChatManager.namespace)/rooms/\(room.id)/messages"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let messageIdPayload = jsonObject as? [String: Int] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                guard let messageId = messageIdPayload["message_id"] else {
//                    completionHandler(nil, PCError.messageIdKeyMissingInMessageCreationResponse(messageIdPayload))
//                    return
//                }
//
//                completionHandler(messageId, nil)
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//
//}
//
//
//// MARK: Typing indicators
//
//extension PCChatManager {
//
//    fileprivate func typingStateChange(
//        eventPayload: [String: Any],
//        room: PCRoom,
//        completionHandler: @escaping (Error?) -> Void
//    ) {
//        guard JSONSerialization.isValidJSONObject(eventPayload) else {
//            completionHandler(PCError.invalidJSONObjectAsData(eventPayload))
//            return
//        }
//
//        guard let data = try? JSONSerialization.data(withJSONObject: eventPayload, options: []) else {
//            completionHandler(PCError.failedToJSONSerializeData(eventPayload))
//            return
//        }
//
//        let path = "/\(PCChatManager.namespace)/rooms/\(room.id)/events"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                // TODO: What is data here?
//
//                completionHandler(nil)
//            },
//            onError: { error in
//                completionHandler(error)
//            }
//        )
//    }
//
//    public func startedTypingIn(_ room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        let eventPayload: [String: Any] = ["name": "typing_start", "data": [:], "user_id": self.userId]
//        self.typingStateChange(eventPayload: eventPayload, room: room, completionHandler: completionHandler)
//    }
//
//    // TODO: Add version of startedTyping that auto-calls stoppedTyping after timeout period, unless
//    // some sort of update event is triggered locally in the SDK
//
//    public func stoppedTypingIn(_ room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        let eventPayload: [String: Any] = ["name": "typing_stop", "data": [:], "user_id": self.userId]
//        self.typingStateChange(eventPayload: eventPayload, room: room, completionHandler: completionHandler)
//    }
//
//}
//
//
//// MARK: User finding & fetching
//
//extension PCChatManager {
//
//    public func user(id: Int, completionHander: @escaping (PCUser?, Error?) -> Void) {
//        if let user = self.users.first(where: { $0.id == id }) {
//            completionHander(user, nil)
//        } else {
//            self.getUser(id: id) { user, err in
//                guard let user = user, err == nil else {
//                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
//                    completionHander(nil, err!)
//                    return
//                }
//
//                self.users.insert(user)
//                completionHander(user, nil)
//            }
//        }
//    }
//
//    public func getUser(id: Int, completionHandler: @escaping (PCUser?, Error?) -> Void) {
//        let path = "/\(PCChatManager.namespace)/users/\(id)"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let userPayload = jsonObject as? [String: Any] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                do {
//                    let user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
//                    completionHandler(user, nil)
//                } catch let err {
//                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
//                    completionHandler(nil, err)
//                    return
//                }
//            },
//            onError: { err in
//                completionHandler(nil, err)
//            }
//        )
//    }
//
//}
//
//
//// MARK: Room finding & fetching
//
//extension PCChatManager {
//
//    public func room(id: Int, completionHander: @escaping (PCRoom?, Error?) -> Void) {
//        if let room = self.currentUser?.rooms.first(where: { $0.id == id }) {
//            completionHander(room, nil)
//        } else {
//            self.getRoom(id: id) { room, err in
//                guard err == nil else {
//                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
//                    completionHander(nil, err!)
//                    return
//                }
//
//                // TODO: Should the room be added to the currentUser?
//
//                completionHander(room!, nil)
//            }
//        }
//    }
//
//    // TODO: Should withMessages be available here?
//
//    public func getRoom(id: Int, withMessages: Int? = nil, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
//        let path = "/\(PCChatManager.namespace)/rooms/\(id)"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)
//
//        if let withMessages = withMessages {
//            let withMessagesQueryItem = URLQueryItem(name: "with_messages", value: String(withMessages))
//            generalRequest.addQueryItems([withMessagesQueryItem])
//        }
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let roomPayload = jsonObject as? [String: Any] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                let room: PCRoom
//
//                do {
//                    room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
//                } catch let err {
//                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
//                    completionHandler(nil, err)
//                    return
//                }
//
//                if withMessages != nil {
//                    guard let messagesPayload = roomPayload["messages"] as? [[String: Any]] else {
//                        completionHandler(nil, PCError.incompleteRoomPayloadInGetRoomResponse(roomPayload))
//                        return
//                    }
//
//                    messagesPayload.forEach { messagePayload in
//                        do {
//                            let message = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)
//                            room.messages.append(message)
//                        } catch let err {
//                            self.app.logger.log(err.localizedDescription, logLevel: .debug)
//                            completionHandler(nil, err)
//                            return
//                        }
//                    }
//                }
//
//                completionHandler(room, nil)
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//
//
//}
//
//
//// MARK: Get rooms for an app
//
//extension PCChatManager {
//
//    public func getRooms(completionHandler: @escaping ([PCRoom]?, Error?) -> Void) {
//        let path = "/\(PCChatManager.namespace)/rooms"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
//                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
//                    return
//                }
//
//                guard let roomsPayload = jsonObject as? [[String: Any]] else {
//                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
//                    return
//                }
//
//                let rooms = roomsPayload.flatMap { roomPayload -> PCRoom? in
//                    do {
//                        return try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
//                    } catch let err {
//                        self.app.logger.log(err.localizedDescription, logLevel: .debug)
//                        return nil
//                    }
//                }
//
//                completionHandler(rooms, nil)
//            },
//            onError: { error in
//                completionHandler(nil, error)
//            }
//        )
//    }
//
//}
//
//
//// MARK: User room membership changes
//
//extension PCChatManager {
//
//    public func join(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        self.add(userIds: [self.userId], to: room, completionHandler: completionHandler)
//    }
//
//    public func leave(room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        self.remove(userIds: [self.userId], from: room, completionHandler: completionHandler)
//    }
//
//    public func add(_ user: PCUser, to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        self.add([user], to: room, completionHandler: completionHandler)
//    }
//
//    public func add(_ users: [PCUser], to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        let userIds = users.map { $0.id }
//        self.add(userIds: userIds, to: room, completionHandler: completionHandler)
//    }
//
//    public func add(userIds: [Int], to room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        self.addOrRemoveUsers(in: room, userIds: userIds, membershipChange: .add, completionHandler: completionHandler)
//    }
//
//    public func remove(_ user: PCUser, from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        self.remove([user], from: room, completionHandler: completionHandler)
//    }
//
//    public func remove(_ users: [PCUser], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        let userIds = users.map { $0.id }
//        self.remove(userIds: userIds, from: room, completionHandler: completionHandler)
//    }
//
//    public func remove(userIds: [Int], from room: PCRoom, completionHandler: @escaping (Error?) -> Void) {
//        self.addOrRemoveUsers(in: room, userIds: userIds, membershipChange: .remove, completionHandler: completionHandler)
//    }
//
//    fileprivate func addOrRemoveUsers(in room: PCRoom, userIds: [Int], membershipChange: PCUserMembershipChange, completionHandler: @escaping (Error?) -> Void) {
//        let userPayload = ["\(membershipChange.rawValue)_user_ids": userIds]
//
//        guard JSONSerialization.isValidJSONObject(userPayload) else {
//            completionHandler(PCError.invalidJSONObjectAsData(userPayload))
//            return
//        }
//
//        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
//            completionHandler(PCError.failedToJSONSerializeData(userPayload))
//            return
//        }
//
//        let path = "/\(PCChatManager.namespace)/rooms/\(room.id)/users"
//        let generalRequest = PPRequestOptions(method: HTTPMethod.PUT.rawValue, path: path, body: data)
//
//        self.app.requestWithRetry(
//            using: generalRequest,
//            onSuccess: { data in
//                // TODO: What is data here?
//
//                completionHandler(nil)
//            },
//            onError: { error in
//                completionHandler(error)
//            }
//        )
//    }
//
//    fileprivate enum PCUserMembershipChange: String {
//        case add
//        case remove
//    }
//
//}
//
