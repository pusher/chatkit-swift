import Foundation
import PusherPlatform
#if os(iOS) || os(macOS)
import BeamsChatkit
#endif

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
    let typingIndicatorManager: PCTypingIndicatorManager
    var delegate: PCChatManagerDelegate {
        didSet {
            userSubscription?.delegate = delegate
            userPresenceSubscriptions.forEach { ($0.value).delegate = delegate }
        }
    }

    // TODO: This should probably be [PCUser] instead, like the users property
    // in PCRoom, or something even simpler
    public var users: Set<PCUser> {
        return self.userStore.users
    }

    public var rooms: [PCRoom] {
        return self.roomStore.rooms.underlyingArray
    }

    public let pathFriendlyID: String

    public internal(set) var userSubscription: PCUserSubscription?
    public internal(set) var presenceSubscription: PCPresenceSubscription?
    public internal(set) var cursorSubscription: PCCursorSubscription?

    private let roomSubscriptionQueue = DispatchQueue(
        label: "com.pusher.chatkit.room-subscriptions"
    )

    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }

    private let chatkitBeamsTokenProviderInstance: Instance
    let instance: Instance
    let filesInstance: Instance
    let cursorsInstance: Instance
    let presenceInstance: Instance

    let connectionCoordinator: PCConnectionCoordinator

    private lazy var readCursorDebouncerManager: PCReadCursorDebouncerManager = {
        return PCReadCursorDebouncerManager(currentUser: self)
    }()

    public internal(set) var userPresenceSubscriptions = PCSynchronizedDictionary<String, PCUserPresenceSubscription>()

    public init(
        id: String,
        pathFriendlyID: String,
        createdAt: String,
        updatedAt: String,
        name: String?,
        avatarURL: String?,
        customData: [String: Any]?,
        instance: Instance,
        chatkitBeamsTokenProviderInstance: Instance,
        filesInstance: Instance,
        cursorsInstance: Instance,
        presenceInstance: Instance,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        cursorStore: PCCursorStore,
        connectionCoordinator: PCConnectionCoordinator,
        delegate: PCChatManagerDelegate
    ) {
        self.id = id
        self.pathFriendlyID = pathFriendlyID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.name = name
        self.avatarURL = avatarURL
        self.customData = customData
        self.instance = instance
        self.chatkitBeamsTokenProviderInstance = chatkitBeamsTokenProviderInstance
        self.filesInstance = filesInstance
        self.cursorsInstance = cursorsInstance
        self.presenceInstance = presenceInstance
        self.userStore = userStore
        self.roomStore = roomStore
        self.cursorStore = cursorStore
        self.connectionCoordinator = connectionCoordinator
        self.delegate = delegate
        self.typingIndicatorManager = PCTypingIndicatorManager(instance: instance)

        self.userStore.onUserStoredHooks.append { [weak self] user in
            guard let strongSelf = self else {
                instance.logger.log(
                    "PCCurrentUser (self) is nil when going to subscribe to user presence after storing user in store",
                    logLevel: .verbose
                )
                return
            }
            strongSelf.subscribeToUserPresence(user: user)
        }
    }

    public func createRoom(
        name: String,
        isPrivate: Bool = false,
        addUserIDs userIDs: [String]? = nil,
        customData: [String: Any]? = nil,
        completionHandler: @escaping PCRoomCompletionHandler
    ) {
        var roomObject: [String: Any] = [
            "name": name,
            "created_by_id": self.id,
            "private": isPrivate,
        ]

        if userIDs != nil && userIDs!.count > 0 {
            roomObject["user_ids"] = userIDs
        }

        if customData != nil {
            roomObject["custom_data"] = customData!
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
                    self.roomStore.addOrMerge(room) { room in
                        self.populateRoomUserStore(room) { room in
                            completionHandler(room, nil)
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

    // MARK: Room membership-related interactions

    public func addUser(_ user: PCUser, to room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        self.addUsers([user], to: room, completionHandler: completionHandler)
    }

    public func addUser(id: String, to roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        self.addOrRemoveUsers(in: roomID, userIDs: [id], membershipChange: .add, completionHandler: completionHandler)
    }

    public func addUsers(_ users: [PCUser], to room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        let userIDs = users.map { $0.id }
        self.addUsers(ids: userIDs, to: room.id, completionHandler: completionHandler)
    }

    public func addUsers(ids: [String], to roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        self.addOrRemoveUsers(in: roomID, userIDs: ids, membershipChange: .add, completionHandler: completionHandler)
    }

    public func removeUser(_ user: PCUser, from room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        self.removeUsers([user], from: room, completionHandler: completionHandler)
    }

    public func removeUser(id: String, from roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        self.removeUsers(ids: [id], from: roomID, completionHandler: completionHandler)
    }

    public func removeUsers(_ users: [PCUser], from room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        let userIDs = users.map { $0.id }
        self.removeUsers(ids: userIDs, from: room.id, completionHandler: completionHandler)
    }

    public func removeUsers(ids: [String], from roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        self.addOrRemoveUsers(in: roomID, userIDs: ids, membershipChange: .remove, completionHandler: completionHandler)
    }

    //MARK: Update Room
    /**
     *  Update a room
     *
     * - parameter room: The room which should be updated.
     * - parameter name: Name of the room.
     * - parameter isPrivate: Indicates if a room should be private or public.
     * - parameter customData: Optional custom data associated with a room.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func updateRoom(
        _ room: PCRoom,
        name: String? = nil,
        isPrivate: Bool? = nil,
        customData: [String: Any]? = nil,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        self.updateRoom(
            roomID: room.id,
            name: name,
            isPrivate: isPrivate,
            customData: customData,
            completionHandler: completionHandler
        )
    }

    /**
     *  Update a room by providing the room id
     *
     * - parameter id: The id of the room which should be updated.
     * - parameter name: Name of the room.
     * - parameter isPrivate: Indicates if a room should be private or public.
     * - parameter customData: Optional custom data associated with a room.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func updateRoom(
        id: String,
        name: String? = nil,
        isPrivate: Bool? = nil,
        customData: [String: Any]? = nil,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        self.updateRoom(
            roomID: id,
            name: name,
            isPrivate: isPrivate,
            customData: customData,
            completionHandler: completionHandler
        )
    }

    fileprivate func updateRoom(
        roomID: String,
        name: String?,
        isPrivate: Bool?,
        customData: [String: Any]?,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        guard name != nil || isPrivate != nil || customData != nil else {
            completionHandler(nil)
            return
        }

        var roomPayload: [String: Any] = [:]
        roomPayload["name"] = name
        roomPayload["private"] = isPrivate

        if customData != nil {
            roomPayload["custom_data"] = customData
        }

        guard JSONSerialization.isValidJSONObject(roomPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(roomPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: roomPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(roomPayload))
            return
        }

        let path = "/rooms/\(roomID)"
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
    public func deleteRoom(_ room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        self.deleteRoom(roomID: room.id, completionHandler: completionHandler)
    }

    /**
     *  Delete a room by providing the room id
     *
     * - parameter id: The id of the room which should be deleted.
     * - parameter completionHandler: Invoked when request failed or completed.
     */
    public func deleteRoom(id: String, completionHandler: @escaping PCErrorCompletionHandler) {
        self.deleteRoom(roomID: id, completionHandler: completionHandler)
    }

    fileprivate func deleteRoom(roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        let path = "/rooms/\(roomID)"
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
        in roomID: String,
        userIDs: [String],
        membershipChange: PCUserMembershipChange,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        let userPayload = ["user_ids": userIDs]

        guard JSONSerialization.isValidJSONObject(userPayload) else {
            completionHandler(PCError.invalidJSONObjectAsData(userPayload))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(userPayload))
            return
        }

        let path = "/rooms/\(roomID)/users/\(membershipChange.rawValue)"
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

    public func joinRoom(_ room: PCRoom, completionHandler: @escaping PCRoomCompletionHandler) {
        self.joinRoom(roomID: room.id, completionHandler: completionHandler)
    }

    public func joinRoom(id: String, completionHandler: @escaping PCRoomCompletionHandler) {
        self.joinRoom(roomID: id, completionHandler: completionHandler)
    }

    fileprivate func joinRoom(roomID: String, completionHandler: @escaping PCRoomCompletionHandler) {
        if let room = self.rooms.first(where: { $0.id == roomID }) {
            completionHandler(room, nil)
            return
        }

        let path = "/users/\(self.pathFriendlyID)/rooms/\(roomID)/join"
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
                    self.roomStore.addOrMerge(room) { room in
                        self.populateRoomUserStore(room) { room in
                            completionHandler(room, nil)
                        }
                    }
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

    fileprivate func populateRoomUserStore(_ room: PCRoom, completionHandler: @escaping (PCRoom) -> Void) {
        let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIDs.count, labelSuffix: "room-users")

        // TODO: Use the soon-to-be-created new version of fetchUsersWithIDs from the
        // userStore

        room.userIDs.forEach { userID in
            self.userStore.user(id: userID) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user during population of room user store")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(
                        "Unable to add user with id \(userID) to room \(room.name): \(err!.localizedDescription)",
                        logLevel: .debug
                    )

                    if roomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                        room.subscription?.delegate?.onUsersUpdated()
                        strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                        completionHandler(room)
                    }

                    return
                }

                room.userStore.addOrMerge(user)

                if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                    room.subscription?.delegate?.onUsersUpdated()
                    strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                    completionHandler(room)
                }
            }
        }
    }

    public func leaveRoom(_ room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        self.leaveRoom(roomID: room.id, completionHandler: completionHandler)
    }

    public func leaveRoom(id roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        self.leaveRoom(roomID: roomID, completionHandler: completionHandler)
    }

    fileprivate func leaveRoom(roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        let path = "/users/\(self.pathFriendlyID)/rooms/\(roomID)/leave"
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

    public func getJoinableRooms(completionHandler: @escaping PCRoomsCompletionHandler) {
        self.getUserRooms(onlyJoinable: true, completionHandler: completionHandler)
    }

    fileprivate func getUserRooms(onlyJoinable: Bool = false, completionHandler: @escaping PCRoomsCompletionHandler) {
        let path = "/users/\(self.pathFriendlyID)/rooms"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        let joinableQueryItemValue = onlyJoinable ? "true" : "false"
        generalRequest.addQueryItems([URLQueryItem(name: "joinable", value: joinableQueryItemValue)])
        self.getRooms(request: generalRequest, completionHandler: completionHandler)
    }

    fileprivate func getRooms(request: PPRequestOptions, completionHandler: @escaping PCRoomsCompletionHandler) {
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

                let rooms = roomsPayload.compactMap { roomPayload -> PCRoom? in
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

    public func typing(in roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        typingIndicatorManager.sendThrottledRequest(
            roomID: roomID,
            completionHandler: completionHandler
        )
    }

    public func typing(in room: PCRoom, completionHandler: @escaping PCErrorCompletionHandler) {
        typing(in: room.id, completionHandler: completionHandler)
    }

    // MARK: Message-related interactions

    func sendMessage(_ messageObject: [String: Any], roomID: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        guard JSONSerialization.isValidJSONObject(messageObject) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(messageObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(messageObject))
            return
        }

        let path = "/rooms/\(roomID)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let messageIDPayload = jsonObject as? [String: Int] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                guard let messageID = messageIDPayload["message_id"] else {
                    completionHandler(nil, PCMessageError.messageIDKeyMissingInMessageCreationResponse(messageIDPayload))
                    return
                }

                completionHandler(messageID, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    func uploadAttachmentAndSendMessage(
        _ messageObject: [String: Any],
        attachment: PCAttachmentType,
        roomID: String,
        completionHandler: @escaping (Int?, Error?) -> Void,
        progressHandler: ((Int64, Int64) -> Void)? = nil
    ) {
        var multipartFormData: ((PPMultipartFormData) -> Void)
        var reqOptions: PPRequestOptions

        switch attachment {
        case .fileData(let data, let name):
            multipartFormData = { $0.append(data, withName: "file", fileName: name) }
            let pathSafeName = pathFriendlyVersion(of: name)
            reqOptions = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: "/rooms/\(roomID)/users/\(pathFriendlyID)/files/\(pathSafeName)")
            break
        case .fileURL(let url, let name):
            multipartFormData = { $0.append(url, withName: "file", fileName: name) }
            let pathSafeName = pathFriendlyVersion(of: name)
            reqOptions = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: "/rooms/\(roomID)/users/\(pathFriendlyID)/files/\(pathSafeName)")
            break
        default:
            sendMessage(messageObject, roomID: roomID, completionHandler: completionHandler)
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

                    self.sendMessage(mutableMessageObject, roomID: roomID, completionHandler: completionHandler)
                } catch let err {
                    completionHandler(nil, err)
                    self.instance.logger.log("Response from uploading attachment to room \(roomID) was invalid", logLevel: .verbose)
                    return
                }
            },
            onError: { err in
                completionHandler(nil, err)
                self.instance.logger.log("Failed to upload attachment to room \(roomID)", logLevel: .verbose)
            },
            progressHandler: progressHandler
        )
    }

    public func sendMessage(
        roomID: String,
        text: String,
        attachment: PCAttachmentType? = nil,
        completionHandler: @escaping (Int?, Error?) -> Void
    ) {
        var messageObject: [String: Any] = [
            "user_id": self.id,
            "text": text
        ]

        guard let attachment = attachment else {
            sendMessage(messageObject, roomID: roomID, completionHandler: completionHandler)
            return
        }

        switch attachment {
        case .fileData(_, _), .fileURL(_, _):
            uploadAttachmentAndSendMessage(
                messageObject,
                attachment: attachment,
                roomID: roomID,
                completionHandler: completionHandler
            )
            break
        case .link(let url, let type):
            messageObject["attachment"] = [
                "resource_link": url,
                "type": type
            ]
            sendMessage(messageObject, roomID: roomID, completionHandler: completionHandler)
            break
        }
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

    public func subscribeToRoom(
        room: PCRoom,
        roomDelegate: PCRoomDelegate,
        messageLimit: Int = 20,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        self.subscribeToRoom(
            room,
            delegate: roomDelegate,
            messageLimit: messageLimit,
            completionHandler: completionHandler
        )
    }

    // TODO: Do we need a Last-Event-ID option here? Probably yes if we get to the point
    // of supporting offline or caching, or someone wants to do that themselves, then
    // offering this as a point to hook into would be an optimisation opportunity
    public func subscribeToRoom(
        id roomID: String,
        roomDelegate: PCRoomDelegate,
        messageLimit: Int = 20,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        self.roomStore.room(id: roomID) { r, err in
            guard err == nil, let room = r else {
                self.instance.logger.log(
                    "Error getting room from room store as part of room subscription process \(err!.localizedDescription)",
                    logLevel: .error
                )
                completionHandler(err)
                return
            }
            self.subscribeToRoom(
                room,
                delegate: roomDelegate,
                messageLimit: messageLimit,
                completionHandler: completionHandler
            )
        }
    }

    fileprivate func subscribeToRoom(
        _ room: PCRoom,
        delegate: PCRoomDelegate,
        messageLimit: Int = 20,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        self.instance.logger.log(
            "About to subscribe to room \(room.debugDescription)",
            logLevel: .verbose
        )

        self.joinRoom(roomID: room.id) { innerRoom, err in
            guard let roomToSubscribeTo = innerRoom, err == nil else {
                self.instance.logger.log(
                    "Error joining room as part of room subscription process \(room.debugDescription)",
                    logLevel: .error
                )
                return
            }

            if room.subscription != nil {
                room.subscription!.end()
                room.subscription = nil
            }

            room.subscription = PCRoomSubscription(
                room: roomToSubscribeTo,
                messageLimit: messageLimit,
                currentUserID: self.id,
                roomDelegate: delegate,
                chatManagerDelegate: self.delegate,
                userStore: self.userStore,
                roomStore: self.roomStore,
                cursorStore: self.cursorStore,
                typingIndicatorManager: self.typingIndicatorManager,
                instance: self.instance,
                cursorsInstance: self.cursorsInstance,
                logger: self.instance.logger,
                completionHandler: completionHandler
            )
        }
    }

    public func fetchMessagesFromRoom(
        _ room: PCRoom,
        initialID: String? = nil,
        limit: Int? = nil,
        direction: PCRoomMessageFetchDirection = .older,
        completionHandler: @escaping ([PCMessage]?, Error?) -> Void
    ) {
        let path = "/rooms/\(room.id)/messages"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        if let initialID = initialID {
            generalRequest.addQueryItems([URLQueryItem(name: "initial_id", value: initialID)])
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

                guard messagesPayload.count > 0 else {
                    completionHandler([], nil)
                    return
                }

                let progressCounter = PCProgressCounter(totalCount: messagesPayload.count, labelSuffix: "message-enricher")
                let messages = PCSynchronizedArray<PCMessage>()
                var basicMessages: [PCBasicMessage] = []

                let messageUserIDs = messagesPayload.compactMap { messagePayload -> String? in
                    do {
                        let basicMessage = try PCPayloadDeserializer.createBasicMessageFromPayload(messagePayload)
                        basicMessages.append(basicMessage)
                        return basicMessage.senderID
                    } catch let err {
                        self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                        return nil
                    }
                }

                let messageUserIDsSet = Set<String>(messageUserIDs)

                self.userStore.fetchUsersWithIDs(messageUserIDsSet) { _, err in
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
                                print("self is nil in enrichment of basicMessage")
                                return
                            }

                            guard let message = message, err == nil else {
                                strongSelf.instance.logger.log(err!.localizedDescription, logLevel: .debug)

                                if progressCounter.incrementFailedAndCheckIfFinished() {
                                    completionHandler(messages.underlyingArray.sorted(by: { $0.id > $1.id }), nil)
                                }

                                return
                            }

                            messages.append(message) {
                                if progressCounter.incrementSuccessAndCheckIfFinished() {
                                    completionHandler(
                                        messages.underlyingArray.sorted(
                                            by: { $0.id < $1.id }
                                        ),
                                        nil
                                    )
                                }
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

    public func readCursor(roomID: String, userID: String? = nil) throws -> PCCursor? {
        guard let room = self.rooms.filter({ $0.id == roomID }).first else {
            throw PCCurrentUserError.mustBeMemberOfRoom
        }

        let userIDToCheck = userID ?? self.id

        if userIDToCheck != self.id && room.subscription == nil {
            throw PCCurrentUserError.noSubscriptionToRoom(room)
        }

        return self.cursorStore.getSync(userID: userIDToCheck, roomID: roomID)
    }

    public func setReadCursor(position: Int, roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        readCursorDebouncerManager.set(cursorPosition: position, inRoomID: roomID, completionHandler: completionHandler)
    }

    func sendReadCursor(position: Int, roomID: String, completionHandler: @escaping PCErrorCompletionHandler) {
        let cursorObject = ["position": position]

        guard JSONSerialization.isValidJSONObject(cursorObject) else {
            completionHandler(PCError.invalidJSONObjectAsData(cursorObject))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: cursorObject, options: []) else {
            completionHandler(PCError.failedToJSONSerializeData(cursorObject))
            return
        }

        let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(roomID)/users/\(self.pathFriendlyID)"
        let cursorRequest = PPRequestOptions(method: HTTPMethod.PUT.rawValue, path: path, body: data)

        self.cursorsInstance.request(
            using: cursorRequest,
            onSuccess: { data in
                self.cursorsInstance.logger.log("Successfully set cursor in room \(roomID)", logLevel: .verbose)
                completionHandler(nil)
            },
            onError: { err in
                self.cursorsInstance.logger.log("Error setting cursor in room \(roomID): \(err.localizedDescription)", logLevel: .debug)
                completionHandler(err)
            }
        )
    }

    fileprivate func subscribeToUserPresence(user: PCUser) {
        guard user.id != self.id else {
            return // don't subscribe to own presence
        }

        guard self.userPresenceSubscriptions[user.id] == nil else {
            return // already subscribed to presence for user
        }

        let path = "/users/\(user.pathFriendlyID)"

        let subscribeRequest = PPRequestOptions(
            method: HTTPMethod.SUBSCRIBE.rawValue,
            path: path
        )

        var resumableSub = PPResumableSubscription(
            instance: self.presenceInstance,
            requestOptions: subscribeRequest
        )

        let userPresenceSubscription = PCUserPresenceSubscription(
            userID: user.id,
            resumableSubscription: resumableSub,
            userStore: self.userStore,
            roomStore: self.roomStore,
            logger: self.presenceInstance.logger,
            delegate: delegate
        )

        self.userPresenceSubscriptions[user.id] = userPresenceSubscription

        self.presenceInstance.subscribeWithResume(
            with: &resumableSub,
            using: subscribeRequest,
            onEvent: { [unowned userPresenceSubscription] eventID, headers, data in
                userPresenceSubscription.handleEvent(eventID: eventID, headers: headers, data: data)
            },
            onError: { err in
                // TODO: What to do with an error? Just log?
                self.cursorsInstance.logger.log(
                    "Error with user presence subscription for user with ID \(user.id): \(err.localizedDescription)",
                    logLevel: .error
                )
            }
        )
    }
}

func reconcileMemberships(
    new: [PCUser],
    old: [PCUser],
    onUserJoinedHook: ((PCUser) -> Void)?,
    onUserLeftHook: ((PCUser) -> Void)?
) {
    let oldSet = Set(old)
    let newSet = Set(new)

    let newMembers = newSet.subtracting(oldSet)
    let membersRemoved = oldSet.subtracting(newSet)

    newMembers.forEach { onUserJoinedHook?($0) }

    membersRemoved.forEach { m in
        onUserLeftHook?(m)
    }
}

public enum PCCurrentUserError: Error {
    case noSubscriptionToRoom(PCRoom)
    case mustBeMemberOfRoom
}

extension PCCurrentUser: PCUpdatable {
    @discardableResult
    func updateWithPropertiesOf(_ currentUser: PCCurrentUser) -> PCCurrentUser {
        self.updatedAt = currentUser.updatedAt
        self.name = currentUser.name
        self.avatarURL = currentUser.avatarURL
        self.customData = currentUser.customData
        self.delegate = currentUser.delegate
        return self
    }
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
    case messageIDKeyMissingInMessageCreationResponse([String: Int])
}

extension PCMessageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .messageIDKeyMissingInMessageCreationResponse(payload):
            return "\"message_id\" key missing from response after message creation: \(payload)"
        }
    }
}

public enum PCRoomMessageFetchDirection: String {
    case older
    case newer
}

public typealias PCErrorCompletionHandler = (Error?) -> Void
public typealias PCRoomCompletionHandler = (PCRoom?, Error?) -> Void
public typealias PCRoomsCompletionHandler = ([PCRoom]?, Error?) -> Void

#if os(iOS) || os(macOS)
// MARK: Beams

private let pushNotifications: PushNotifications = PushNotifications.shared

extension PCCurrentUser {
    /**
     Start PushNotifications service.
     */
    public func enablePushNotifications() {
        let chatkitBeamsTokenProvider = ChatkitBeamsTokenProvider(instance: self.chatkitBeamsTokenProviderInstance)

        pushNotifications.start(instanceId: self.instance.id, tokenProvider: chatkitBeamsTokenProvider)
        pushNotifications.clearAllState { error in
            guard error == nil else {
                return self.instance.logger.log("Error occured while clearing the state: \(error!)", logLevel: .error)
            }

            self.setUser()
        }

        ChatManager.registerForRemoteNotifications()
    }

    private func setUser() {
        do {
            try pushNotifications.setUserId(self.id, completion: { error in
                guard error == nil else {
                    return self.instance.logger.log("Error occured while setting the user: \(error!)", logLevel: .error)
                }

                self.instance.logger.log("Push Notifications service enabled 🎉", logLevel: .debug)
            })
        }
        catch UserValidationtError.userAlreadyExists {
            self.instance.logger.log("User already exists.", logLevel: .error)
        }
        catch UserValidationtError.beamsTokenProviderNotSetException {
            self.instance.logger.log("Beams Token Provider not set.", logLevel: .error)
        }
        catch TokenProviderError.error(let error) {
            self.instance.logger.log("\(error)", logLevel: .error)
        }
        catch PCTokenProviderError.failedToDeserializeJSON(let error) {
            self.instance.logger.log("Failed to deserialize JSON: \(error)", logLevel: .error)
        }
        catch {
            self.instance.logger.log("Unexpected error: \(error)", logLevel: .error)
        }
    }
}
#endif
