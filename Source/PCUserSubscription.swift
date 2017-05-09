import PusherPlatform

public class PCUserSubscription {

    // TODO: Do we need to be careful of retain cycles here?

    public let app: App
    public let resumableSubscription: PPResumableSubscription

    public internal(set) var delegate: PCDelegate?

    public var connectCompletionHandlers: [(PCCurrentUser?, Error?) -> Void]

    public init(
        app: App,
        resumableSubscription: PPResumableSubscription,
        delegate: PCDelegate? = nil,
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

        guard let userId = userPayload["id"] as? Int,
              let createdAt = userPayload["created_at"] as? String,
              let updatedAt = userPayload["updated_at"] as? String
        else {
            callConnectCompletionHandlers(
                currentUser: nil,
                error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "user",
                    apiEventType: eventType,
                    payload: userPayload
                )
            )
            return
        }

        let currentUser = PCCurrentUser(
            id: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: userPayload["name"] as? String,
            customId: userPayload["custom_id"] as? String,
            customData: userPayload["custom_data"] as? [String: Any],
            rooms: [],
            app: self.app
        )

        let rooms = roomsPayload.flatMap { roomPayload -> PCRoom? in
            guard let roomId = roomPayload["id"] as? Int,
                  let roomName = roomPayload["name"] as? String,
                  let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
                  let roomCreatedAt = roomPayload["created_at"] as? String,
                  let roomUpdatedAt = roomPayload["updated_at"] as? String,
                  let memberships = roomPayload["memberships"] as? [[String: Any]]
            else {
                self.app.logger.log("Incomplete room payload in initial_state event: \(roomPayload)", logLevel: .debug)
                return nil
            }

            let users = memberships.flatMap { membership -> PCUser? in
                guard let membershipUserPayload = membership["user"] as? [String: Any] else {
                    self.app.logger.log(
                        "Incomplete membership payload in initial_state event for room: \(roomName)",
                        logLevel: .debug
                    )
                    return nil
                }

                do {
                    return try PCPayloadDeserializer.createUserFromPayload(membershipUserPayload)
                } catch let err {
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    return nil
                }
            }

            return PCRoom(
                id: roomId,
                name: roomName,
                createdByUserId: roomCreatorUserId,
                createdAt: roomCreatedAt,
                updatedAt: roomUpdatedAt,
                users: users
            )
        }

        currentUser.rooms = rooms

        callConnectCompletionHandlers(currentUser: currentUser, error: nil)
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
            self.delegate?.addedToRoom(room)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: roomPayload
                )
            )
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
            self.delegate?.removedFromRoom(room)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: roomPayload
                )
            )
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
            self.delegate?.roomUpdated(room)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: roomPayload
                )
            )
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
            self.delegate?.roomDeleted(room)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: roomPayload
                )
            )
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
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "user",
                    apiEventType: eventType,
                    payload: userPayload
                )
            )
            return
        }

        let room: PCRoom

        do {
            room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: roomPayload
                )
            )
            return
        }

        self.delegate?.userJoinedRoom(room, user: user)
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
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "user",
                    apiEventType: eventType,
                    payload: userPayload
                )
            )
            return
        }

        let room: PCRoom

        do {
            room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "room",
                    apiEventType: eventType,
                    payload: roomPayload
                )
            )
            return
        }

        self.delegate?.userLeftRoom(room, user: user)
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

            // TODO: This is what should actually be being called
//            self.delegate?.messageReceived(room: room, message: message)

            self.delegate?.messageReceived(roomId: message.roomId, message: message)
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(
                PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(
                    key: "message",
                    apiEventType: eventType,
                    payload: messagePayload
                )
            )
        }
    }
}

public enum PCAPIEventError: Error {
    case eventTypeNameMissingInAPIEventPayload([String: Any])
    case apiEventDataMissingInAPIEventPayload([String: Any])
    case keyNotPresentInPCAPIEventPayload(key: String, apiEventType: PCAPIEventType, payload: [String: Any])
    case incompleteDataForKeyInPCAPIEventPayload(key: String, apiEventType: PCAPIEventType, payload: [String: Any])
}

extension PCAPIEventError: LocalizedError {

}

public enum PCError: Error {
    case invalidJSONObjectAsData(Any)
    case failedToJSONSerializeData(Any)

    case failedToDeserializeJSON(Data)
    case failedToCastJSONObjectToDictionary(Any)


    case userIdNotFoundInResponseJSON([String: Any])

    case roomCreationResponsePayloadIncomplete([String: Any])


    // TODO: This does not belong here

    case incompleteRoomPayloadInGetRoomResponse([String: Any])

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
