import Foundation
import PusherPlatform

public final class PCUserSubscription {

    // TODO: Do we need to be careful of retain cycles here? e.g. weak instance

    let instance: Instance
    public let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public internal(set) var delegate: PCChatManagerDelegate
    public var connectCompletionHandlers: [(PCCurrentUser?, Error?) -> Void]

    public var currentUser: PCCurrentUser?

    public init(
        instance: Instance,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        delegate: PCChatManagerDelegate,
        connectCompletionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        self.instance = instance
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.delegate = delegate
        self.connectCompletionHandlers = [connectCompletionHandler]
    }

    public func handleEvent(eventId _: String, headers _: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.instance.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventNameString = json["event_name"] as? String else {
            self.instance.logger.log("Event name missing for API event: \(json)", logLevel: .debug)
            return
        }

        // TODO: Decide if we even need this in the client

        //        guard let timestamp = json["timestamp"] as? String else {
        //            return
        //        }

        guard let eventName = PCAPIEventName(rawValue: eventNameString) else {
            self.instance.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.instance.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

        let userId = json["user_id"] as? String

        self.instance.logger.log("Received event name: \(eventNameString), and data: \(apiEventData)", logLevel: .verbose)

        switch eventName {
        case .initial_state:
            parseInitialStatePayload(eventName, data: apiEventData, userStore: self.userStore)
        case .added_to_room:
            parseAddedToRoomPayload(eventName, data: apiEventData)
        case .removed_from_room:
            parseRemovedFromRoomPayload(eventName, data: apiEventData)
        case .room_updated:
            parseRoomUpdatedPayload(eventName, data: apiEventData)
        case .room_deleted:
            parseRoomDeletedPayload(eventName, data: apiEventData)
        case .user_joined:
            parseUserJoinedPayload(eventName, data: apiEventData)
        case .user_left:
            parseUserLeftPayload(eventName, data: apiEventData)
        case .typing_start:
            parseTypingStartPayload(eventName, data: apiEventData, userId: userId!)
        case .typing_stop:
            parseTypingStopPayload(eventName, data: apiEventData, userId: userId!)
        }
    }

    fileprivate func callConnectCompletionHandlers(currentUser: PCCurrentUser?, error: Error?) {
        for connectCompletionHandler in self.connectCompletionHandlers {
            connectCompletionHandler(currentUser, error)
        }
    }
}

extension PCUserSubscription {
    fileprivate func parseInitialStatePayload(_ eventName: PCAPIEventName, data: [String: Any], userStore: PCGlobalUserStore) {
        guard let roomsPayload = data["rooms"] as? [[String: Any]] else {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "rooms",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let userPayload = data["current_user"] as? [String: Any] else {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "user",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        let receivedCurrentUser: PCCurrentUser

        do {
            receivedCurrentUser = try PCPayloadDeserializer.createCurrentUserFromPayload(userPayload, instance: self.instance, userStore: userStore)
        } catch let err {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: err
            )
            return
        }

        let wasExistingCurrentUser = self.currentUser != nil

        // If the currentUser property is already set then the assumption is that there was
        // already a user subscription and so instead of setting the property to a new
        // PCCurrentUser, we update the existing one to have the most up-to-date state
        if let currentUser = self.currentUser {
            currentUser.updateWithPropertiesOf(receivedCurrentUser)
        } else {
            self.currentUser = receivedCurrentUser
        }

        // If a presenceSubscription already exists then we want to create a new one
        // to ensure that the most up-to-date state is received, so we first close the
        // existing subscription, if it was still open
        if let presSub = self.currentUser?.presenceSubscription {
            presSub.end()
            self.currentUser!.presenceSubscription = nil
        }

        guard roomsPayload.count > 0 else {
            self.callConnectCompletionHandlers(currentUser: self.currentUser, error: nil)
            self.currentUser!.setupPresenceSubscription(delegate: self.delegate)
            return
        }

        let roomsAddedToRoomStoreProgressCounter = PCProgressCounter(
            totalCount: roomsPayload.count,
            labelSuffix: "roomstore-room-append"
        )

        var combinedRoomUserIds = Set<String>()
        var roomsFromConnection = [PCRoom]()

        roomsPayload.forEach { roomPayload in
            do {
                let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

                combinedRoomUserIds.formUnion(room.userIds)
                roomsFromConnection.append(room)

                self.currentUser!.roomStore.addOrMerge(room) { _ in
                    if roomsAddedToRoomStoreProgressCounter.incrementSuccessAndCheckIfFinished() {
                        self.callConnectCompletionHandlers(currentUser: self.currentUser, error: nil)
                        self.fetchInitialUserInformationForUserIds(combinedRoomUserIds, currentUser: self.currentUser!)
                        if wasExistingCurrentUser {
                            self.reconcileExistingRoomStoreWithRoomsReceivedOnConnection(roomsFromConnection: roomsFromConnection)
                        }
                    }
                }
            } catch let err {
                self.instance.logger.log(
                    "Incomplete room payload in initial_state event: \(roomPayload). Error: \(err.localizedDescription)",
                    logLevel: .debug
                )
                if roomsAddedToRoomStoreProgressCounter.incrementFailedAndCheckIfFinished() {
                    self.callConnectCompletionHandlers(currentUser: self.currentUser, error: nil)
                    self.fetchInitialUserInformationForUserIds(combinedRoomUserIds, currentUser: self.currentUser!)
                    if wasExistingCurrentUser {
                        self.reconcileExistingRoomStoreWithRoomsReceivedOnConnection(roomsFromConnection: roomsFromConnection)
                    }
                }
            }
        }
    }

    fileprivate func fetchInitialUserInformationForUserIds(_ userIds: Set<String>, currentUser: PCCurrentUser) {
        self.userStore.initialFetchOfUsersWithIds(userIds) { _, err in
            guard err == nil else {
                self.instance.logger.log(
                    "Unable to fetch user information after successful connection: \(err!.localizedDescription)",
                    logLevel: .debug
                )
                return
            }

            let combinedRoomUsersProgressCounter = PCProgressCounter(totalCount: currentUser.roomStore.rooms.count, labelSuffix: "room-users-combined")

            // TODO: This could be a lot more efficient
            currentUser.roomStore.rooms.forEach { room in
                let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIds.count, labelSuffix: "room-users")

                room.userIds.forEach { userId in
                    self.userStore.user(id: userId) { [weak self] user, err in
                        guard let strongSelf = self else {
                            print("self is nil when user store returns user after initial fetch of users")
                            return
                        }

                        guard let user = user, err == nil else {
                            strongSelf.instance.logger.log(
                                "Unable to add user with id \(userId) to room \(room.name): \(err!.localizedDescription)",
                                logLevel: .debug
                            )
                            if roomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                                room.subscription?.delegate?.usersUpdated()
                                strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)

                                if combinedRoomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                                    currentUser.setupPresenceSubscription(delegate: strongSelf.delegate)
                                }
                            }

                            return
                        }

                        room.userStore.addOrMerge(user)

                        if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                            room.subscription?.delegate?.usersUpdated()
                            strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)

                            if combinedRoomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                                currentUser.setupPresenceSubscription(delegate: strongSelf.delegate)
                            }
                        }
                    }
                }
            }
        }
    }

    fileprivate func reconcileExistingRoomStoreWithRoomsReceivedOnConnection(roomsFromConnection: [PCRoom]) {
        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate.error(error: PCError.currentUserIsNil)
            return
        }

        let roomStoreRooms = Set<PCRoom>(currentUser.roomStore.rooms.underlyingArray)
        let mostRecentConnectionRooms = Set<PCRoom>(roomsFromConnection)
        let noLongerAMemberOfRooms = roomStoreRooms.subtracting(mostRecentConnectionRooms)

        noLongerAMemberOfRooms.forEach { room in

            // TODO: Not sure if this is the best way of communicating that while the subscription
            // was closed there was an event that meant that the current user is no longer a
            // member of a given room

            self.delegate.removedFromRoom(room: room)
        }
    }

    fileprivate func parseAddedToRoomPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

            self.currentUser?.roomStore.addOrMerge(room) { room in
                self.delegate.addedToRoom(room: room)
                self.instance.logger.log("Added to room: \(room.name)", logLevel: .verbose)
            }

            // TODO: Use the soon-to-be-created new version of fetchUsersWithIds from the
            // userStore

            let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIds.count, labelSuffix: "room-users")

            room.userIds.forEach { userId in
                self.userStore.user(id: userId) { [weak self] user, err in
                    guard let strongSelf = self else {
                        print("self is nil when user store returns user after parsing added to room event")
                        return
                    }

                    guard let user = user, err == nil else {
                        strongSelf.instance.logger.log(
                            "Unable to add user with id \(userId) to room \(room.name): \(err!.localizedDescription)",
                            logLevel: .debug
                        )

                        if roomUsersProgressCounter.incrementFailedAndCheckIfFinished() {
                            room.subscription?.delegate?.usersUpdated()
                            strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                        }

                        return
                    }

                    room.userStore.addOrMerge(user)

                    if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                        room.subscription?.delegate?.usersUpdated()
                        strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                    }
                }
            }
        } catch let err {
            self.instance.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate.error(error: err)
        }
    }

    fileprivate func parseRemovedFromRoomPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomId = data["room_id"] as? Int else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        self.currentUser?.roomStore.remove(id: roomId) { room in
            guard let roomRemovedFrom = room else {
                self.instance.logger.log("Received \(eventName.rawValue) API event but room \(roomId) not found in local store of joined rooms", logLevel: .debug)
                return
            }

            self.delegate.removedFromRoom(room: roomRemovedFrom)
            self.instance.logger.log("Removed from room: \(roomRemovedFrom.name)", logLevel: .verbose)
        }
    }

    fileprivate func parseRoomUpdatedPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

            self.currentUser?.roomStore.room(id: room.id) { roomToUpdate, err in

                guard let roomToUpdate = roomToUpdate, err == nil else {
                    self.instance.logger.log(err!.localizedDescription, logLevel: .debug)
                    return
                }

                roomToUpdate.updateWithPropertiesOfRoom(room)
                self.delegate.roomUpdated(room: roomToUpdate)
                self.instance.logger.log("Room updated: \(room.name)", logLevel: .verbose)
            }
        } catch let err {
            self.instance.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate.error(error: err)
        }
    }

    fileprivate func parseRoomDeletedPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomId = data["room_id"] as? Int else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate.error(error: PCError.currentUserIsNil)
            return
        }

        currentUser.roomStore.remove(id: roomId) { room in
            guard let deletedRoom = room else {
                self.instance.logger.log("Room \(roomId) was deleted but was not found in local store of joined rooms", logLevel: .debug)
                return
            }

            self.delegate.roomDeleted(room: deletedRoom)
            self.instance.logger.log("Room deleted: \(deletedRoom.name)", logLevel: .verbose)
        }
    }

    fileprivate func parseUserJoinedPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomId = data["room_id"] as? Int else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let userId = data["user_id"] as? String else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "user_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate.error(error: PCError.currentUserIsNil)
            return
        }

        currentUser.roomStore.room(id: roomId) { room, err in
            guard let room = room, err == nil else {
                self.instance.logger.log(
                    "User with id \(userId) joined room with id \(roomId) but no information about the room could be retrieved. Error was: \(err!.localizedDescription)",
                    logLevel: .error
                )
                self.delegate.error(error: err!)
                return
            }

            currentUser.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing user joined event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(
                        "User with id \(userId) joined room with id \(roomId) but no information about the user could be retrieved. Error was: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    strongSelf.delegate.error(error: err!)
                    return
                }

                let addedOrMergedUser = room.userStore.addOrMerge(user)
                room.userIds.insert(addedOrMergedUser.id)

                strongSelf.delegate.userJoinedRoom(room: room, user: addedOrMergedUser)
                room.subscription?.delegate?.userJoined(user: addedOrMergedUser)
                strongSelf.instance.logger.log("User \(user.displayName) joined room: \(room.name)", logLevel: .verbose)
            }
        }
    }

    fileprivate func parseUserLeftPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomId = data["room_id"] as? Int else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let userId = data["user_id"] as? String else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "user_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate.error(error: PCError.currentUserIsNil)
            return
        }

        currentUser.roomStore.room(id: roomId) { room, err in
            guard let room = room, err == nil else {
                self.instance.logger.log(
                    "User with id \(userId) left room with id \(roomId) but no information about the room could be retrieved. Error was: \(err!.localizedDescription)",
                    logLevel: .error
                )
                self.delegate.error(error: err!)
                return
            }

            currentUser.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing user left event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(
                        "User with id \(userId) left room with id \(roomId) but no information about the user could be retrieved. Error was: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    strongSelf.delegate.error(error: err!)
                    return
                }

                let roomUserIdIndex = room.userIds.index(of: user.id)

                if let indexToRemove = roomUserIdIndex {
                    room.userIds.remove(at: indexToRemove)
                }

                room.userStore.remove(id: user.id)

                strongSelf.delegate.userLeftRoom(room: room, user: user)
                room.subscription?.delegate?.userLeft(user: user)
                strongSelf.instance.logger.log("User \(user.displayName) left room: \(room.name)", logLevel: .verbose)
            }
        }
    }

    fileprivate func parseTypingStartPayload(_ eventName: PCAPIEventName, data: [String: Any], userId: String) {
        guard let roomId = data["room_id"] as? Int else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate.error(error: PCError.currentUserIsNil)
            return
        }

        currentUser.roomStore.room(id: roomId) { room, err in
            guard let room = room, err == nil else {
                self.instance.logger.log(err!.localizedDescription, logLevel: .error)
                self.delegate.error(error: err!)
                return
            }

            currentUser.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing typing start event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(err!.localizedDescription, logLevel: .error)
                    strongSelf.delegate.error(error: err!)
                    return
                }

                strongSelf.delegate.userStartedTyping(room: room, user: user)
                room.subscription?.delegate?.userStartedTyping(user: user)
                strongSelf.instance.logger.log("\(user.displayName) started typing in room \(room.name)", logLevel: .verbose)
            }
        }
    }

    fileprivate func parseTypingStopPayload(_ eventName: PCAPIEventName, data: [String: Any], userId: String) {
        guard let roomId = data["room_id"] as? Int else {
            self.delegate.error(
                error: PCAPIEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    apiEventName: eventName,
                    payload: data
                )
            )
            return
        }

        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate.error(error: PCError.currentUserIsNil)
            return
        }

        currentUser.roomStore.room(id: roomId) { room, err in
            guard let room = room, err == nil else {
                self.instance.logger.log(err!.localizedDescription, logLevel: .error)
                self.delegate.error(error: err!)
                return
            }

            currentUser.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing typing stop event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(err!.localizedDescription, logLevel: .error)
                    strongSelf.delegate.error(error: err!)
                    return
                }

                strongSelf.delegate.userStoppedTyping(room: room, user: user)
                room.subscription?.delegate?.userStoppedTyping(user: user)
                strongSelf.instance.logger.log("\(user.displayName) stopped typing in room \(room.name)", logLevel: .verbose)
            }
        }
    }
}

public enum PCAPIEventError: Error {
    case eventTypeNameMissingInAPIEventPayload([String: Any])
    case apiEventDataMissingInAPIEventPayload([String: Any])
    case keyNotPresentInEventPayload(key: String, apiEventName: PCAPIEventName, payload: [String: Any])
}

extension PCAPIEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .eventTypeNameMissingInAPIEventPayload(payload):
            return "Event type missing in API event payload: \(payload)"
        case let .apiEventDataMissingInAPIEventPayload(payload):
            return "Data missing in API event payload: \(payload)"
        case let .keyNotPresentInEventPayload(key, apiEventName, payload):
            return "\(key) missing in \(apiEventName.rawValue) API event payload: \(payload)"
        }
    }
}

public enum PCError: Error {
    case invalidJSONObjectAsData(Any)
    case failedToJSONSerializeData(Any)
    case failedToDeserializeJSON(Data)
    case failedToCastJSONObjectToDictionary(Any)
    case currentUserIsNil
}

extension PCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidJSONObjectAsData(jsonObject):
            return "Invalid object for JSON serialization: \(jsonObject)"
        case let .failedToJSONSerializeData(jsonObject):
            return "Failed to JSON serialize object: \(jsonObject)"
        case let .failedToDeserializeJSON(data):
            if let dataString = String(data: data, encoding: .utf8) {
                return "Failed to deserialize JSON: \(dataString)"
            } else {
                return "Failed to deserialize JSON"
            }
        case let .failedToCastJSONObjectToDictionary(jsonObject):
            return "Failed to cast JSON object to Dictionary: \(jsonObject)"
        case .currentUserIsNil:
            return "currentUser property is nil for PCUserSubscription"
        }
    }
}

public enum PCAPIEventType: String {
    case api
    case user
}

public enum PCAPIEventName: String {
    case initial_state
    case added_to_room
    case removed_from_room
    case room_updated
    case room_deleted
    case user_joined
    case user_left
    case typing_start
    case typing_stop
}

public enum PCUserSubscriptionState {
    case opening
    case open
    case resuming
    case end(statusCode: Int?, headers: [String: String]?, info: Any?)
    case error(error: Error)
}
