import PusherPlatform

public class PCUserSubscription {

    // TODO: Do we need to be careful of retain cycles here?

    public let app: App
    public let resumableSubscription: PPResumableSubscription

    public internal(set) var delegate: PCUserSubscriptionDelegate?

    public var connectCompletionHandlers: [(PCCurrentUser?, Error?) -> Void]

    public var currentUser: PCCurrentUser? = nil

    public init(
        app: App,
        resumableSubscription: PPResumableSubscription,
        delegate: PCUserSubscriptionDelegate? = nil,
        connectCompletionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        self.app = app
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.connectCompletionHandlers = [connectCompletionHandler]
    }

    public func handleEvent(eventId: String, headers: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.app.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventTypeName = json["event_name"] as? String else {
            self.app.logger.log("Event type name missing for API event: \(json)", logLevel: .debug)
            return
        }

        // TODO: Decide if we even need this in the client

//        guard let timestamp = json["timestamp"] as? String else {
//            return
//        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.app.logger.log("Missing data for API event: \(json)", logLevel: .debug)
            return
        }

        guard let eventType = PCAPIEventType(rawValue: eventTypeName) else {
            self.app.logger.log("Unsupported API event type received: \(eventTypeName)", logLevel: .debug)
            return
        }

        self.app.logger.log("Received data: \(apiEventData) for event type: \(eventTypeName)", logLevel: .verbose)

        switch eventType {
        case .initial_state:
            parseInitialStatePayload(eventType, data: apiEventData)
        case .added_to_room:
            parseAddedToRoomPayload(eventType, data: apiEventData)
        case .removed_from_room:
            parseRemovedFromRoomPayload(eventType, data: apiEventData)
        case .room_updated:
            parseRoomUpdatedPayload(eventType, data: apiEventData)
        case .room_deleted:
            parseRoomDeletedPayload(eventType, data: apiEventData)
        case .user_joined:
            parseUserJoinedPayload(eventType, data: apiEventData)
        case .user_left:
            parseUserLeftPayload(eventType, data: apiEventData)
        case .new_room_message:
            parseNewRoomMessagePayload(eventType, data: apiEventData)
        }
    }

    fileprivate func callConnectCompletionHandlers(currentUser: PCCurrentUser?, error: Error?) {
        for connectCompletionHandler in self.connectCompletionHandlers {
            connectCompletionHandler(currentUser, error)
        }
    }
}

extension PCUserSubscription {
    fileprivate func parseInitialStatePayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomsPayload = data["rooms"] as? [[String: Any]] else {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "rooms",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        guard let userPayload = data["user"] as? [String: Any] else {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "user",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        let receivedCurrentUser: PCCurrentUser

        do {
            receivedCurrentUser = try PCPayloadDeserializer.createCurrentUserFromPayload(userPayload, app: self.app)
        } catch let err {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: err
            )
            return
        }

        roomsPayload.forEach { roomPayload in
            guard let roomId = roomPayload["id"] as? Int,
                  let roomName = roomPayload["name"] as? String,
                  let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
                  let roomCreatedAt = roomPayload["created_at"] as? String,
                  let roomUpdatedAt = roomPayload["updated_at"] as? String,
                  let memberships = roomPayload["memberships"] as? [[String: Any]]
            else {
                self.app.logger.log("Incomplete room payload in initial_state event: \(roomPayload)", logLevel: .debug)
                return
            }

            let room = PCRoom(
                id: roomId,
                name: roomName,
                createdByUserId: roomCreatorUserId,
                createdAt: roomCreatedAt,
                updatedAt: roomUpdatedAt
            )

            memberships.forEach { membership in
                guard let membershipUserPayload = membership["user"] as? [String: Any] else {
                    self.app.logger.log(
                        "Incomplete membership payload in initial_state event for room: \(roomName)",
                        logLevel: .debug
                    )
                    return
                }

                do {
                    let user = try PCPayloadDeserializer.createUserFromPayload(membershipUserPayload)
                    room.users.append(user)
                } catch let err {
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    return
                }
            }

            receivedCurrentUser.rooms.append(room)
        }

        self.currentUser = receivedCurrentUser
        callConnectCompletionHandlers(currentUser: self.currentUser, error: nil)
    }

    fileprivate func parseAddedToRoomPayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
            self.currentUser?.rooms.append(room)
            self.delegate?.addedToRoom(room)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
        }
    }

    fileprivate func parseRemovedFromRoomPayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

            guard let removedRoom = self.currentUser?.rooms.remove(where: { $0.id == room.id }) else {
                // TODO: Log and call delelgate?.error() ?
                return
            }

            // TODO: Should this always be called?
            self.delegate?.removedFromRoom(removedRoom)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
        }
    }

    fileprivate func parseRoomUpdatedPayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

            guard let roomToUpdate = self.currentUser?.rooms.first(where: { $0.id == room.id }) else {
                // TODO: Log and call delelgate?.error() ?
                return
            }

            roomToUpdate.updateWithPropertiesOfRoom(room)

            // TODO: Should this always be called?
            self.delegate?.roomUpdated(roomToUpdate)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
        }
    }

    fileprivate func parseRoomDeletedPayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        do {
            let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)

            guard let deletedRoom = self.currentUser?.rooms.remove(where: { $0.id == room.id }) else {
                // TODO: Log and call delelgate?.error() ?
                return
            }

            // TODO: Should this always be called?
            self.delegate?.roomDeleted(deletedRoom)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
        }
    }

    fileprivate func parseUserJoinedPayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        guard let userPayload = data["user"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "user",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        let user: PCUser

        do {
            user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
            return
        }

        let room: PCRoom

        do {
            room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
            return
        }

        guard let roomUserJoined = self.currentUser?.rooms.first(where: { $0.id == room.id }) else {
            // TODO: Log and call delelgate?.error() ?
            return
        }

        roomUserJoined.users.append(user)
        self.delegate?.userJoinedRoom(roomUserJoined, user: user)
    }

    fileprivate func parseUserLeftPayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        guard let userPayload = data["user"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "user",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        let user: PCUser

        do {
            user = try PCPayloadDeserializer.createUserFromPayload(userPayload)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
            return
        }

        let room: PCRoom

        do {
            room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
            return
        }

        guard let roomUserLeft = self.currentUser?.rooms.first(where: { $0.id == room.id }) else {
            // TODO: Log and call delelgate?.error() ?
            return
        }

        guard let userThatLeft = roomUserLeft.users.remove(where: { $0.id == user.id }) else {
            // TODO: Log and call delelgate?.error() ?
            return
        }

        self.delegate?.userLeftRoom(roomUserLeft, user: userThatLeft)
    }

    fileprivate func parseNewRoomMessagePayload(_ eventType: PCAPIEventType, data: [String: Any]) {
        guard let messagePayload = data["message"] as? [String: Any] else {
            self.delegate?.error(
                PCAPIEventError.keyNotPresentInPCAPIEventPayload(
                    key: "message",
                    apiEventType: eventType,
                    payload: data
                )
            )
            return
        }

        do {
            let message = try PCPayloadDeserializer.createMessageFromPayload(messagePayload)

            guard let roomWithNewMessage = self.currentUser?.rooms.first(where: { $0.id == message.roomId }) else {
                // TODO: Log and call delelgate?.error() ?
                return
            }

            roomWithNewMessage.messages.append(message)
            self.delegate?.messageReceived(room: roomWithNewMessage, message: message)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(err)
        }
    }
}

public enum PCAPIEventError: Error {
    case eventTypeNameMissingInAPIEventPayload([String: Any])
    case apiEventDataMissingInAPIEventPayload([String: Any])
    case keyNotPresentInPCAPIEventPayload(key: String, apiEventType: PCAPIEventType, payload: [String: Any])
}

extension PCAPIEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .eventTypeNameMissingInAPIEventPayload(let payload):
            return "Event type missing in API event payload: \(payload)"
        case .apiEventDataMissingInAPIEventPayload(let payload):
            return "Data missing in API event payload: \(payload)"
        case .keyNotPresentInPCAPIEventPayload(let key, let apiEventType, let payload):
            return "\(key) missing in \(apiEventType.rawValue) API event payload: \(payload)"
        }
    }
}

public enum PCError: Error {
    case invalidJSONObjectAsData(Any)
    case failedToJSONSerializeData(Any)

    case failedToDeserializeJSON(Data)
    case failedToCastJSONObjectToDictionary(Any)


    // TODO: Where do these belong?!


    case userIdNotFoundInResponseJSON([String: Any])

    case roomCreationResponsePayloadIncomplete([String: Any])


    case incompleteRoomPayloadInGetRoomResponse([String: Any])

    case messageIdKeyMissingInMessageCreationResponse([String: Int])

}

extension PCError: LocalizedError {

}

public enum PCAPIEventType: String {
    case initial_state
    case added_to_room
    case removed_from_room
    case new_room_message
    case room_updated
    case room_deleted
    case user_joined
    case user_left
}

public enum PCUserSubscriptionState {
    case opening
    case open
    case resuming
    case end(statusCode: Int?, headers: [String: String]?, info: Any?)
    case error(error: Error)
}
