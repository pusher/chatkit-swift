import Foundation
import PusherPlatform

public final class PCUserSubscription {
    unowned let instance: Instance
    unowned let filesInstance: Instance
    unowned let cursorsInstance: Instance
    unowned let presenceInstance: Instance
    public let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public internal(set) weak var delegate: PCChatManagerDelegate?
    let userID: String
    let pathFriendlyUserID: String
    let connectionCoordinator: PCConnectionCoordinator
    let initialStateHandler: ((roomsPayload: [[String: Any]], currentUserPayload: [String: Any])) -> Void

    public weak var currentUser: PCCurrentUser?

    public init(
        instance: Instance,
        filesInstance: Instance,
        cursorsInstance: Instance,
        presenceInstance: Instance,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        delegate: PCChatManagerDelegate,
        userID: String,
        pathFriendlyUserID: String,
        connectionCoordinator: PCConnectionCoordinator,
        initialStateHandler: @escaping ((roomsPayload: [[String: Any]], currentUserPayload: [String: Any])) -> Void
    ) {
        self.instance = instance
        self.filesInstance = filesInstance
        self.cursorsInstance = cursorsInstance
        self.presenceInstance = presenceInstance
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.delegate = delegate
        self.userID = userID
        self.pathFriendlyUserID = pathFriendlyUserID
        self.connectionCoordinator = connectionCoordinator
        self.initialStateHandler = initialStateHandler
    }

    public func handleEvent(eventID _: String, headers _: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.instance.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventNameString = json["event_name"] as? String else {
            self.instance.logger.log("Event name missing for API event: \(json)", logLevel: .debug)
            return
        }

        guard let eventName = PCAPIEventName(rawValue: eventNameString) else {
            self.instance.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.instance.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

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
        }
    }

    func end() {
        self.resumableSubscription.end()
    }

    fileprivate func informConnectionCoordinatorOfCurrentUserCompletion(currentUser: PCCurrentUser?, error: Error?) {
        connectionCoordinator.connectionEventCompleted(PCConnectionEvent(currentUser: currentUser, error: error))
    }
}

extension PCUserSubscription {
    fileprivate func parseInitialStatePayload(_ eventName: PCAPIEventName, data: [String: Any], userStore: PCGlobalUserStore) {
        guard let roomsPayload = data["rooms"] as? [[String: Any]] else {
            informConnectionCoordinatorOfCurrentUserCompletion(
                currentUser: nil,
                error: PCSubscriptionEventError.keyNotPresentInEventPayload(
                    key: "rooms",
                    eventName: eventName.rawValue,
                    payload: data
                )
            )
            return
        }

        guard let currentUserPayload = data["current_user"] as? [String: Any] else {
            informConnectionCoordinatorOfCurrentUserCompletion(
                currentUser: nil,
                error: PCSubscriptionEventError.keyNotPresentInEventPayload(
                    key: "current_user",
                    eventName: eventName.rawValue,
                    payload: data
                )
            )
            return
        }

        self.initialStateHandler((roomsPayload: roomsPayload, currentUserPayload: currentUserPayload))
    }

    fileprivate func parseAddedToRoomPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.onError(
                error: PCSubscriptionEventError.keyNotPresentInEventPayload(
                    key: "room",
                    eventName: eventName.rawValue,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

            self.currentUser?.roomStore.addOrMerge(room) { room in
                self.delegate?.onAddedToRoom(room)
                self.instance.logger.log("Added to room: \(room.name)", logLevel: .verbose)
            }

            // TODO: Use the soon-to-be-created new version of fetchUsersWithIDs from the
            // userStore

            let roomUsersProgressCounter = PCProgressCounter(totalCount: room.userIDs.count, labelSuffix: "room-users")

            room.userIDs.forEach { userID in
                self.userStore.user(id: userID) { [weak self] user, err in
                    guard let strongSelf = self else {
                        print("self is nil when user store returns user after parsing added to room event")
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
                        }

                        return
                    }

                    room.userStore.addOrMerge(user)

                    if roomUsersProgressCounter.incrementSuccessAndCheckIfFinished() {
                        room.subscription?.delegate?.onUsersUpdated()
                        strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
                    }
                }
            }
        } catch let err {
            self.instance.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.onError(error: err)
        }
    }

    fileprivate func parseRemovedFromRoomPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomID = data["room_id"] as? String else {
            self.delegate?.onError(
                error: PCSubscriptionEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    eventName: eventName.rawValue,
                    payload: data
                )
            )
            return
        }

        self.currentUser?.roomStore.remove(id: roomID) { room in
            guard let roomRemovedFrom = room else {
                self.instance.logger.log("Received \(eventName.rawValue) API event but room \(roomID) not found in local store of joined rooms", logLevel: .debug)
                return
            }

            self.delegate?.onRemovedFromRoom(roomRemovedFrom)
            self.instance.logger.log("Removed from room: \(roomRemovedFrom.name)", logLevel: .verbose)
        }
    }

    fileprivate func parseRoomUpdatedPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.onError(
                error: PCSubscriptionEventError.keyNotPresentInEventPayload(
                    key: "room",
                    eventName: eventName.rawValue,
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

                roomToUpdate.updateWithPropertiesOf(room)
                self.delegate?.onRoomUpdated(room: roomToUpdate)
                self.instance.logger.log("Room updated: \(room.name)", logLevel: .verbose)
            }
        } catch let err {
            self.instance.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.onError(error: err)
        }
    }

    fileprivate func parseRoomDeletedPayload(_ eventName: PCAPIEventName, data: [String: Any]) {
        guard let roomID = data["room_id"] as? String else {
            self.delegate?.onError(
                error: PCSubscriptionEventError.keyNotPresentInEventPayload(
                    key: "room_id",
                    eventName: eventName.rawValue,
                    payload: data
                )
            )
            return
        }

        guard let currentUser = self.currentUser else {
            self.instance.logger.log("currentUser property not set on PCUserSubscription", logLevel: .error)
            self.delegate?.onError(error: PCError.currentUserIsNil)
            return
        }

        currentUser.roomStore.remove(id: roomID) { room in
            guard let deletedRoom = room else {
                self.instance.logger.log("Room \(roomID) was deleted but was not found in local store of joined rooms", logLevel: .debug)
                return
            }

            self.delegate?.onRoomDeleted(room: deletedRoom)
            self.instance.logger.log("Room deleted: \(deletedRoom.name)", logLevel: .verbose)
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
}

public enum PCUserSubscriptionState {
    case opening
    case open
    case resuming
    case end(statusCode: Int?, headers: [String: String]?, info: Any?)
    case error(error: Error)
}
