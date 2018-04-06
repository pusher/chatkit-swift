import Foundation
import PusherPlatform

public final class PCCurrentUser {
    public let id: String
    public let createdAt: String
    public var updatedAt: String
    public var name: String?
    public var avatarURL: String?
    public var customData: [String: Any]?

    let userStore: PCGlobalUserStore
    let roomStore: PCRoomStore
    let cursorStore: PCCursorStore

    public typealias ErrorCompletionHandler = (Error?) -> Void
    public typealias RoomCompletionHandler = (PCRoom?, Error?) -> Void
    public typealias RoomsCompletionHandler = ([PCRoom]?, Error?) -> Void

    // TODO: This should probably be [PCUser] instead, like the users property
    // in PCRoom, or something even simpler
    public var users: Set<PCUser> {
        return self.userStore.users
    }

    public var rooms: [PCRoom] {
        return self.roomStore.rooms.underlyingArray
    }

    public let pathFriendlyId: String

    public internal(set) var userSubscription: PCUserSubscription?
    public internal(set) var presenceSubscription: PCPresenceSubscription?
    public internal(set) var cursorSubscription: PCCursorSubscription?

    var typingIndicatorManagers: [Int: PCTypingIndicatorManager] = [:]
    private var typingIndicatorQueue = DispatchQueue(label: "com.pusher.chatkit.typing-indicators")

    let instance: Instance
    let filesInstance: Instance
    let cursorsInstance: Instance
    let presenceInstance: Instance

    let connectionCoordinator: PCConnectionCoordinator

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    public var createdAtDate: Date { return self.dateFormatter.date(from: self.createdAt)! }
    public var updatedAtDate: Date { return self.dateFormatter.date(from: self.updatedAt)! }

    public init(
        id: String,
        pathFriendlyId: String,
        createdAt: String,
        updatedAt: String,
        name: String?,
        avatarURL: String?,
        customData: [String: Any]?,
        instance: Instance,
        filesInstance: Instance,
        cursorsInstance: Instance,
        presenceInstance: Instance,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        cursorStore: PCCursorStore,
        connectionCoordinator: PCConnectionCoordinator
    ) {
        self.id = id
        self.pathFriendlyId = pathFriendlyId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.avatarURL = avatarURL
        self.customData = customData
        self.instance = instance
        self.filesInstance = filesInstance
        self.cursorsInstance = cursorsInstance
        self.presenceInstance = presenceInstance
        self.userStore = userStore
        self.roomStore = roomStore
        self.cursorStore = cursorStore
        self.connectionCoordinator = connectionCoordinator
    }

    func updateWithPropertiesOf(_ currentUser: PCCurrentUser) {
        self.updatedAt = currentUser.updatedAt
        self.name = currentUser.name
        self.customData = currentUser.customData
    }

    public func createRoom(
        name: String,
        isPrivate: Bool = false,
        addUserIds userIds: [String]? = nil,
        completionHandler: @escaping RoomCompletionHandler
    ) {
        var roomObject: [String: Any] = [
            "name": name,
            "created_by_id": self.id,
            "private": isPrivate,
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

        let path = "/rooms"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
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
                    self.roomStore.addOrMerge(room) { room in completionHandler(room, nil) }
                    self.populateRoomUserStore(room)
                } catch let err {
                    completionHandler(nil, err)
                }
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    // MARK: Room membership-related interactions

    public func addUser(_ user: PCUser, to room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        self.addUsers([user], to: room, completionHandler: completionHandler)
    }

    public func addUser(id: String, to roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        self.addOrRemoveUsers(in: roomId, userIds: [id], membershipChange: .add, completionHandler: completionHandler)
    }

    public func addUsers(_ users: [PCUser], to room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        let userIds = users.map { $0.id }
        self.addUsers(ids: userIds, to: room.id, completionHandler: completionHandler)
    }

    public func addUsers(ids: [String], to roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        self.addOrRemoveUsers(in: roomId, userIds: ids, membershipChange: .add, completionHandler: completionHandler)
    }

    public func removeUser(_ user: PCUser, from room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        self.removeUsers([user], from: room, completionHandler: completionHandler)
    }

    public func removeUser(id: String, from roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        self.removeUsers(ids: [id], from: roomId, completionHandler: completionHandler)
    }

    public func removeUsers(_ users: [PCUser], from room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        let userIds = users.map { $0.id }
        self.removeUsers(ids: userIds, from: room.id, completionHandler: completionHandler)
    }

    public func removeUsers(ids: [String], from roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        self.addOrRemoveUsers(in: roomId, userIds: ids, membershipChange: .remove, completionHandler: completionHandler)
    }

    //MARK: Update Room
    /**
     *  Update a room
     *
     * - parameter room: The room which should be updated.
     * - parameter name: Name of the room.
     * - parameter isPrivate: Indicates if a room should be private or public.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func updateRoom(_ room: PCRoom, name: String? = nil, isPrivate: Bool? = nil, completionHandler: @escaping ErrorCompletionHandler) {
        self.updateRoom(roomId: room.id, name: name, isPrivate: isPrivate, completionHandler: completionHandler)
    }

    /**
     *  Update a room by providing the room id
     *
     * - parameter id: The id of the room which should be updated.
     * - parameter name: Name of the room.
     * - parameter isPrivate: Indicates if a room should be private or public.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func updateRoom(id: Int, name: String? = nil, isPrivate: Bool? = nil, completionHandler: @escaping ErrorCompletionHandler) {
        self.updateRoom(roomId: id, name: name, isPrivate: isPrivate, completionHandler: completionHandler)
    }

    fileprivate func updateRoom(roomId: Int, name: String?, isPrivate: Bool?, completionHandler: @escaping ErrorCompletionHandler) {
        guard name != nil || isPrivate != nil else {
            completionHandler(nil)
            return
        }

        var userPayload: [String : Any] = [:]
        userPayload["name"] = name
        userPayload["private"] = isPrivate

        guard JSONSerialization.isValidJSONObject(userPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(userPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(userPayload))
            return
        }

        let path = "/rooms/\(roomId)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.PUT.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { _ in
                completionHandler(nil)
            },
            onError: { error in
                completionHandler(error)
            }
        )
    }

    //MARK: Delete Room
    /**
     *  Delete a room
     *
     * - parameter room: The room which should be deleted.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func deleteRoom(_ room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        self.deleteRoom(roomId: room.id, completionHandler: completionHandler)
    }

    /**
     *  Delete a room by providing the room id
     *
     * - parameter id: The id of the room which should be deleted.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func deleteRoom(id: Int, completionHandler: @escaping ErrorCompletionHandler) {
        self.deleteRoom(roomId: id, completionHandler: completionHandler)
    }

    fileprivate func deleteRoom(roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        let path = "/rooms/\(roomId)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.DELETE.rawValue, path: path)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { _ in
              completionHandler(nil)
            },
            onError: { error in
              completionHandler(error)
            }
        )
    }

    fileprivate func addOrRemoveUsers(
        in roomId: Int,
        userIds: [String],
        membershipChange: PCUserMembershipChange,
        completionHandler: @escaping ErrorCompletionHandler
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

        let path = "/rooms/\(roomId)/users/\(membershipChange.rawValue)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.PUT.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { _ in
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

    public func joinRoom(_ room: PCRoom, completionHandler: @escaping RoomCompletionHandler) {
        self.joinRoom(roomId: room.id, completionHandler: completionHandler)
    }

    public func joinRoom(id: Int, completionHandler: @escaping RoomCompletionHandler) {
        self.joinRoom(roomId: id, completionHandler: completionHandler)
    }

    fileprivate func joinRoom(roomId: Int, completionHandler: @escaping RoomCompletionHandler) {
        if let room = self.rooms.first(where: { $0.id == roomId }) {
            completionHandler(room, nil)
            return
        }

        let path = "/users/\(self.pathFriendlyId)/rooms/\(roomId)/join"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path)

        self.instance.requestWithRetry(
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
                    self.roomStore.addOrMerge(room) { room in completionHandler(room, nil) }
                    self.populateRoomUserStore(room)
                } catch let err {
                    self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    fileprivate func populateRoomUserStore(_ room: PCRoom) {
        let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIds.count, labelSuffix: "room-users")

        // TODO: Use the soon-to-be-created new version of fetchUsersWithIds from the
        // userStore

        room.userIds.forEach { userId in
            self.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user during population of room user store")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(
                        "Unable to add user with id \(userId) to room \(room.name): \(err!.localizedDescription)",
                        logLevel: .debug
                    )

                    if roomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                        room.subscription?.delegate.usersUpdated()
                        strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                    }

                    return
                }

                room.userStore.addOrMerge(user)

                if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                    room.subscription?.delegate.usersUpdated()
                    strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                }
            }
        }
    }

    public func leaveRoom(_ room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        self.leaveRoom(roomId: room.id, completionHandler: completionHandler)
    }

    public func leaveRoom(id roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        self.leaveRoom(id: roomId, completionHandler: completionHandler)
    }

    fileprivate func leaveRoom(roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        let path = "/users/\(self.pathFriendlyId)/rooms/\(roomId)/leave"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { _ in
                completionHandler(nil)
            },
            onError: { error in
                completionHandler(error)
            }
        )
    }

    // MARK: Room fetching

    public func getJoinableRooms(completionHandler: @escaping RoomsCompletionHandler) {
        self.getUserRooms(onlyJoinable: true, completionHandler: completionHandler)
    }

    fileprivate func getUserRooms(onlyJoinable: Bool = false, completionHandler: @escaping RoomsCompletionHandler) {
        let path = "/users/\(self.pathFriendlyId)/rooms"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        let joinableQueryItemValue = onlyJoinable ? "true" : "false"
        generalRequest.addQueryItems([URLQueryItem(name: "joinable", value: joinableQueryItemValue)])
        self.getRooms(request: generalRequest, completionHandler: completionHandler)
    }

    fileprivate func getRooms(request: PPRequestOptions, completionHandler: @escaping RoomsCompletionHandler) {
        self.instance.requestWithRetry(
            using: request,
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
                        self.instance.logger.log(err.localizedDescription, logLevel: .debug)
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
        completionHandler: @escaping ErrorCompletionHandler
    ) {
        guard JSONSerialization.isValidJSONObject(eventPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(eventPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: eventPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(eventPayload))
            return
        }

        let path = "/rooms/\(roomId)/events"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { _ in
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

    func startedTypingIn(roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        let eventPayload: [String: Any] = ["name": "typing_start", "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: roomId, completionHandler: completionHandler)
    }

    func stoppedTypingIn(roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        let eventPayload: [String: Any] = ["name": "typing_stop", "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: roomId, completionHandler: completionHandler)
    }

    public func startedTypingIn(_ room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        let eventPayload: [String: Any] = ["name": "typing_start", "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: room.id, completionHandler: completionHandler)
    }

    public func stoppedTypingIn(_ room: PCRoom, completionHandler: @escaping ErrorCompletionHandler) {
        let eventPayload: [String: Any] = ["name": "typing_stop", "user_id": self.id]
        self.typingStateChange(eventPayload: eventPayload, roomId: room.id, completionHandler: completionHandler)
    }

    // MARK: Message-related interactions

    @available(*, deprecated: 0.5.0, message: "use sendMessage instead")
    public func addMessage(text: String, to room: PCRoom, completionHandler: @escaping (Int?, Error?) -> Void) {
        let messageObject: [String: Any] = [
            "text": text,
            "user_id": self.id,
        ]

        guard JSONSerialization.isValidJSONObject(messageObject) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(messageObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(messageObject))
            return
        }

        let path = "/rooms/\(room.id)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
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

    func sendMessage(_ messageObject: [String: Any], roomId: Int, completionHandler: @escaping (Int?, Error?) -> Void) {
        guard JSONSerialization.isValidJSONObject(messageObject) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(messageObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(messageObject))
            return
        }

        let path = "/rooms/\(roomId)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
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

    func uploadAttachmentAndSendMessage(
        _ messageObject: [String: Any],
        attachment: PCAttachmentType,
        roomId: Int,
        completionHandler: @escaping (Int?, Error?) -> Void,
        progressHandler: ((Int64, Int64) -> Void)? = nil
    ) {
        var multipartFormData: ((PPMultipartFormData) -> Void)
        var reqOptions: PPRequestOptions

        switch attachment {
        case .fileData(let data, let name):
            multipartFormData = { $0.append(data, withName: "file", fileName: name) }
            reqOptions = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: "/rooms/\(roomId)/files/\(name)")
            break
        case .fileURL(let url, let name):
            multipartFormData = { $0.append(url, withName: "file", fileName: name) }
            reqOptions = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: "/rooms/\(roomId)/files/\(name)")
            break
        default:
            sendMessage(messageObject, roomId: roomId, completionHandler: completionHandler)
            return
        }

        self.filesInstance.upload(
            using: reqOptions,
            multipartFormData: multipartFormData,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let uploadPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                do {
                    let attachmentUploadResponse = try PCPayloadDeserializer.createAttachmentUploadResponseFromPayload(uploadPayload)

                    var mutableMessageObject = messageObject
                    mutableMessageObject["attachment"] = [
                        "resource_link": attachmentUploadResponse.link,
                        "type": attachmentUploadResponse.type
                    ]

                    self.sendMessage(mutableMessageObject, roomId: roomId, completionHandler: completionHandler)
                } catch let err {
                    completionHandler(nil, err)
                    self.instance.logger.log("Response from uploading attachment to room \(roomId) was invalid", logLevel: .verbose)
                    return
                }
            },
            onError: { err in
                completionHandler(nil, err)
                self.instance.logger.log("Failed to upload attachment to room \(roomId)", logLevel: .verbose)
            },
            progressHandler: progressHandler
        )
    }

    public func sendMessage(
        roomId: Int,
        text: String? = nil,
        attachmentType: PCAttachmentType? = nil,
        completionHandler: @escaping (Int?, Error?) -> Void
        ) {
        var messageObject: [String: Any] = [
            "user_id": self.id
        ]
        
        if let text = text {
            messageObject["text"] = text
        }
        
        guard let attachmentType = attachmentType else {
            sendMessage(messageObject, roomId: roomId, completionHandler: completionHandler)
            return
        }
        
        switch attachmentType {
        case .fileData(_, _), .fileURL(_, _):
            uploadAttachmentAndSendMessage(
                messageObject,
                attachment: attachmentType,
                roomId: roomId,
                completionHandler: completionHandler
            )
            break
        case .link(let url, let type):
            messageObject["attachment"] = [
                "resource_link": url,
                "type": type
            ]
            sendMessage(messageObject, roomId: roomId, completionHandler: completionHandler)
            break
        }
    }

    public func fetchAttachment(_ link: String, completionHandler: @escaping (PCFetchedAttachment?, Error?) -> Void) {
        let options = PPRequestOptions(method: HTTPMethod.GET.rawValue, destination: .absolute(link))

        self.filesInstance.request(
            using: options,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let attachmentPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                do {
                    let fetchedAttachment = try PCPayloadDeserializer.createFetchedAttachmentFromPayload(attachmentPayload)
                    completionHandler(fetchedAttachment, nil)
                } catch let err {
                    completionHandler(nil, err)
                }
            }
        )
    }

    public func downloadAttachment(
        _ link: String,
        to destination: PCDownloadFileDestination? = nil,
        onSuccess: ((URL) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        progressHandler: ((Int64, Int64) -> Void)? = nil
    )  {
        let reqOptions = PPRequestOptions(
            method: HTTPMethod.GET.rawValue,
            destination: .absolute(link),
            shouldFetchToken: false
        )
        self.instance.download(
            using: reqOptions,
            to: destination,
            onSuccess: onSuccess,
            onError: onError,
            progressHandler: progressHandler
        )
    }

    // TODO: Do I need to add a Last-Event-ID option here?
    public func subscribeToRoom(room: PCRoom, roomDelegate: PCRoomDelegate, messageLimit: Int = 20) {
        self.instance.logger.log(
            "About to subscribe to room \(room.debugDescription)",
            logLevel: .verbose
        )

        self.joinRoom(roomId: room.id) { innerRoom, err in
            guard let roomToSubscribeTo = innerRoom, err == nil else {
                self.instance.logger.log(
                    "Error joining room as part of room subscription process \(room.debugDescription)",
                    logLevel: .error
                )
                return
            }

            let messageSub = self.subscribeToRoomMessages(
                room: roomToSubscribeTo,
                delegate: roomDelegate,
                messageLimit: messageLimit
            )
            let cursorSub = self.subscribeToRoomCursors(
                room: roomToSubscribeTo,
                delegate: roomDelegate
            )

            room.subscription = PCRoomSubscription(
                messageSubscription: messageSub,
                cursorSubscription: cursorSub,
                delegate: roomDelegate
            )
        }
    }

    fileprivate func subscribeToRoomMessages(
        room: PCRoom,
        delegate: PCRoomDelegate,
        messageLimit: Int
    ) -> PCMessageSubscription {
        let path = "/rooms/\(room.id)"

        // TODO: What happens if you provide both a message_limit and a Last-Event-ID?
        let subscribeRequest = PPRequestOptions(
            method: HTTPMethod.SUBSCRIBE.rawValue,
            path: path,
            queryItems: [
                URLQueryItem(name: "user_id", value: self.id),
                URLQueryItem(name: "message_limit", value: String(messageLimit)),
            ]
        )

        var resumableSub = PPResumableSubscription(
            instance: self.instance,
            requestOptions: subscribeRequest
        )

        let messageSubscription = PCMessageSubscription(
            delegate: delegate,
            resumableSubscription: resumableSub,
            logger: self.instance.logger,
            basicMessageEnricher: PCBasicMessageEnricher(
                userStore: self.userStore,
                // TODO: This should probably be a room store
                room: room,
                logger: self.instance.logger
            )
        )

        self.instance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: messageSubscription.handleEvent
            // TODO: Should we be handling onError here somehow?
        )

        return messageSubscription
    }

    fileprivate func subscribeToRoomCursors(room: PCRoom, delegate: PCRoomDelegate) -> PCCursorSubscription {
        let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(room.id)"

        let subscribeRequest = PPRequestOptions(
            method: HTTPMethod.SUBSCRIBE.rawValue,
            path: path
        )

        var resumableSub = PPResumableSubscription(
            instance: self.cursorsInstance,
            requestOptions: subscribeRequest
        )

        let cursorSubscription = PCCursorSubscription(
            delegate: delegate,
            resumableSubscription: resumableSub,
            cursorStore: cursorStore,
            connectionCoordinator: connectionCoordinator,
            logger: self.cursorsInstance.logger,
            initialStateHandler: { err in
                // TODO: Only consider the room subscription open when both the
                // room subscription and cursor subscription have opened
            }
        )

        self.cursorsInstance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: cursorSubscription.handleEvent
            // TODO: Should we be handling onError here somehow?
        )

        return cursorSubscription
    }

    public func fetchMessagesFromRoom(
        _ room: PCRoom,
        initialId: String? = nil,
        limit: Int? = nil,
        direction: PCRoomMessageFetchDirection = .older,
        completionHandler: @escaping ([PCMessage]?, Error?) -> Void
    ) {
        let path = "/rooms/\(room.id)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        if let initialId = initialId {
            generalRequest.addQueryItems([URLQueryItem(name: "initial_id", value: initialId)])
        }

        if let limit = limit {
            generalRequest.addQueryItems([URLQueryItem(name: "limit", value: String(limit))])
        }

        generalRequest.addQueryItems([URLQueryItem(name: "direction", value: direction.rawValue)])

        self.instance.requestWithRetry(
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

                let progressCounter = PCProgressCounter(totalCount: messagesPayload.count, labelSuffix: "message-enricher")
                let messages = PCSynchronizedArray<PCMessage>()
                var basicMessages: [PCBasicMessage] = []

                let messageUserIds = messagesPayload.flatMap { messagePayload -> String? in
                    do {
                        let basicMessage = try PCPayloadDeserializer.createBasicMessageFromPayload(messagePayload)
                        basicMessages.append(basicMessage)
                        return basicMessage.senderId
                    } catch let err {
                        self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                        return nil
                    }
                }

                let messageUserIdsSet = Set<String>(messageUserIds)

                self.userStore.fetchUsersWithIds(messageUserIdsSet) { _, err in
                    if let err = err {
                        self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                    }

                    let messageEnricher = PCBasicMessageEnricher(
                        userStore: self.userStore,
                        room: room,
                        logger: self.instance.logger
                    )

                    basicMessages.forEach { basicMessage in
                        messageEnricher.enrich(basicMessage) { [weak self] message, err in
                            guard let strongSelf = self else {
                                print("self is enrichment of basicMessage has completed")
                                return
                            }

                            guard let message = message, err == nil else {
                                strongSelf.instance.logger.log(err!.localizedDescription, logLevel: .debug)

                                if progressCounter.incrementFailedAndCheckIfFinished() {
                                    completionHandler(messages.underlyingArray.sorted(by: { $0.id > $1.id }), nil)
                                }

                                return
                            }

                            messages.append(message)
                            if progressCounter.incrementSuccessAndCheckIfFinished() {
                                completionHandler(messages.underlyingArray.sorted(by: { $0.id > $1.id }), nil)
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

    public func readCursor(roomId: Int, userId: String? = nil) throws -> PCCursor? {
        guard let room = self.rooms.filter({ $0.id == roomId }).first else {
            throw PCCurrentUserError.mustBeMemberOfRoom
        }

        let userIdToCheck = userId ?? self.id

        if userIdToCheck != self.id && room.subscription == nil {
            throw PCCurrentUserError.noSubscriptionToRoom(room)
        }

        return self.cursorStore.getSync(userId: userIdToCheck, roomId: roomId)
    }

    public func setReadCursor(position: Int, roomId: Int, completionHandler: @escaping ErrorCompletionHandler) {
        let cursorObject = [ "position": position ]

        guard JSONSerialization.isValidJSONObject(cursorObject) else {
            completionHandler(PCError.invalidJSONObjectAsData(cursorObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: cursorObject, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(cursorObject))
            return
        }

        let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(roomId)/users/\(self.pathFriendlyId)"
        let cursorRequest = PPRequestOptions(method: HTTPMethod.PUT.rawValue, path: path, body: data)

        self.cursorsInstance.request(
            using: cursorRequest,
            onSuccess: { data in
                self.cursorsInstance.logger.log("Successfully set cursor in room \(roomId)", logLevel: .verbose)
                completionHandler(nil)
            },
            onError: { err in
                self.cursorsInstance.logger.log("Error setting cursor in room \(roomId): \(err.localizedDescription)", logLevel: .debug)
                completionHandler(err)
            }
        )
  }
}

public enum PCCurrentUserError: Error {
    case noSubscriptionToRoom(PCRoom)
    case mustBeMemberOfRoom
}

extension PCCurrentUserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .noSubscriptionToRoom(room):
            return "You must be subscribed to room \(room.name) to get read cursors from it"
        case .mustBeMemberOfRoom:
            return "You must be a member of a room to get the read cursors for it"
        }
    }
}

public enum PCMessageError: Error {
    case messageIdKeyMissingInMessageCreationResponse([String: Int])
}

extension PCMessageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .messageIdKeyMissingInMessageCreationResponse(payload):
            return "\"message_id\" key missing from response after message creation: \(payload)"
        }
    }
}

public enum PCRoomMessageFetchDirection: String {
    case older
    case newer
}
