import PusherPlatform

public class PCUserSubscription {

    // TODO: Do we need to be careful of retain cycles here?

    // TODO: Probs doesn't need app

    // TODO: Bigger question - how should requests etc be made? Overall architecture
    // needs some further thought

    let app: App
    public internal(set) var delegate: PCDelegate?
    let resumableSubscription: ResumableSubscription
    public var connectCompletionHandlers: [(PCCurrentUser?, Error?) -> Void]

    public init(
        app: App,
        delegate: PCDelegate? = nil,
        resumableSubscription: ResumableSubscription,
        connectCompletionHandler: @escaping (PCCurrentUser?, Error?) -> Void
    ) {
        self.app = app
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.connectCompletionHandlers = [connectCompletionHandler]
    }

    public func handleEvent(eventId: String, headers: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            DefaultLogger.Logger.log(message: "Failed to cast JSON object to Dictionary: \(data)")
            return
        }

        guard let eventTypeName = json["event_name"] as? String else {
            DefaultLogger.Logger.log(message: "Event type name missing for API event: \(json)")
            return
        }

        // TODO: Decide if we even need this in the client

        //        guard let timestamp = json["timestamp"] as? String else {
        //            return
        //        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            DefaultLogger.Logger.log(message: "Missing data for API event: \(json)")
            return
        }

        guard let eventType = PCAPIEventType(rawValue: eventTypeName) else {
            DefaultLogger.Logger.log(message: "Unsupported API event type received: \(eventTypeName)")
            return
        }

        switch eventType {
        case .initial_state:
            parseInitialStatePayload(data: apiEventData)
        case .added_to_room:
            parseAddedToRoomPayload(data: apiEventData)
        case .removed_from_room:
            print("removed_from_room")
        case .room_updated:
            print("room_updated")
        case .room_deleted:
            print("room_deleted")
        case .user_joined:
            parseUserJoinedPayload(data: apiEventData)
        case .user_left:
            parseUserLeftPayload(data: apiEventData)
        case .new_room_message:
            parseNewRoomMessagePayload(data: apiEventData)
        }

        //        let event = PCAPIEvent(eventType: eventType, data: apiEventData, timestamp: timestamp)

        DefaultLogger.Logger.log(message: "Got some data: \(apiEventData) for event type: \(eventTypeName)")
    }

    fileprivate func callConnectCompletionHandlers(currentUser: PCCurrentUser?, error: Error?) {
        for connectCompletionHandler in self.connectCompletionHandlers {
            connectCompletionHandler(currentUser, error)
        }
    }
}

extension PCUserSubscription {
    fileprivate func parseInitialStatePayload(data: [String: Any]) {
        guard let roomsPayload = data["rooms"] as? [[String: Any]] else {
            callConnectCompletionHandlers(currentUser: nil, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "rooms", apiEventType: .initial_state, payload: data))
            return
        }

        guard let userPayload = data["user"] as? [String: Any] else {
            callConnectCompletionHandlers(currentUser: nil, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "user", apiEventType: .initial_state, payload: data))
            return
        }

        guard let userId = userPayload["id"] as? Int,
              let createdAt = userPayload["created_at"] as? String,
              let updatedAt = userPayload["updated_at"] as? String
        else {
            callConnectCompletionHandlers(currentUser: nil, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "user", apiEventType: .initial_state, payload: userPayload))
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
                DefaultLogger.Logger.log(message: "Incomplete room payload in initial_state event: \(roomPayload)")
                return nil
            }

            let users = memberships.flatMap { membership -> PCUser? in
                guard let membershipUserPayload = membership["user"] as? [String: Any] else {
                    DefaultLogger.Logger.log(message: "Incomplete membership payload in initial_state event for room: \(roomName)")
                    return nil
                }

                guard let userId = membershipUserPayload["id"] as? Int,
                      let createdAt = membershipUserPayload["created_at"] as? String,
                      let updatedAt = membershipUserPayload["updated_at"] as? String
                else {
                    // TODO: Log or complete with error here?
                    DefaultLogger.Logger.log(message: "Incomplete user payload in initial_state event for room: \(roomName)")
                    return nil
                }

                return PCUser(
                    id: userId,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    name: membershipUserPayload["name"] as? String,
                    customId: membershipUserPayload["custom_id"] as? String,
                    customData: membershipUserPayload["custom_data"] as? [String: Any]
                )
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

    fileprivate func parseAddedToRoomPayload(data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(eventType: .added_to_room, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "room", apiEventType: .added_to_room, payload: data))
            return
        }

        guard let roomId = roomPayload["id"] as? Int,
              let roomName = roomPayload["name"] as? String,
              let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
              let roomCreatedAt = roomPayload["created_at"] as? String,
              let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            self.delegate?.error(eventType: .user_joined, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "room", apiEventType: .added_to_room, payload: roomPayload))
            return
        }

        let room = PCRoom(
            id: roomId,
            name: roomName,
            createdByUserId: roomCreatorUserId,
            createdAt: roomCreatedAt,
            updatedAt: roomUpdatedAt
        )

        self.delegate?.addedTo(room: room)
    }

    fileprivate func parseUserJoinedPayload(data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(eventType: .user_joined, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "room", apiEventType: .user_joined, payload: data))
            return
        }

        guard let userPayload = data["user"] as? [String: Any] else {
            self.delegate?.error(eventType: .user_joined, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "user", apiEventType: .user_joined, payload: data))
            return
        }

        guard let userId = userPayload["id"] as? Int,
              let createdAt = userPayload["created_at"] as? String,
              let updatedAt = userPayload["updated_at"] as? String
        else {
            self.delegate?.error(eventType: .user_joined, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "user", apiEventType: .user_joined, payload: userPayload))
            return
        }

        let user = PCUser(
            id: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: userPayload["name"] as? String,
            customId: userPayload["custom_id"] as? String,
            customData: userPayload["custom_data"] as? [String: Any]
        )

        guard let roomId = roomPayload["id"] as? Int,
              let roomName = roomPayload["name"] as? String,
              let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
              let roomCreatedAt = roomPayload["created_at"] as? String,
              let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            self.delegate?.error(eventType: .user_joined, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "room", apiEventType: .user_joined, payload: roomPayload))
            return
        }

        let room = PCRoom(
            id: roomId,
            name: roomName,
            createdByUserId: roomCreatorUserId,
            createdAt: roomCreatedAt,
            updatedAt: roomUpdatedAt
        )

        self.delegate?.userJoined(room: room, user: user)
    }

    fileprivate func parseUserLeftPayload(data: [String: Any]) {
        guard let roomPayload = data["room"] as? [String: Any] else {
            self.delegate?.error(eventType: .user_left, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "room", apiEventType: .user_left, payload: data))
            return
        }

        guard let userPayload = data["user"] as? [String: Any] else {
            self.delegate?.error(eventType: .user_left, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "user", apiEventType: .user_left, payload: data))
            return
        }

        guard let userId = userPayload["id"] as? Int,
              let createdAt = userPayload["created_at"] as? String,
              let updatedAt = userPayload["updated_at"] as? String
        else {
            self.delegate?.error(eventType: .user_left, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "user", apiEventType: .user_left, payload: userPayload))
            return
        }

        let user = PCUser(
            id: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: userPayload["name"] as? String,
            customId: userPayload["custom_id"] as? String,
            customData: userPayload["custom_data"] as? [String: Any]
        )

        guard let roomId = roomPayload["id"] as? Int,
              let roomName = roomPayload["name"] as? String,
              let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
              let roomCreatedAt = roomPayload["created_at"] as? String,
              let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            self.delegate?.error(eventType: .user_left, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "room", apiEventType: .user_left, payload: roomPayload))
            return
        }

        let room = PCRoom(
            id: roomId,
            name: roomName,
            createdByUserId: roomCreatorUserId,
            createdAt: roomCreatedAt,
            updatedAt: roomUpdatedAt
        )

        self.delegate?.userLeft(room: room, user: user)
    }

    fileprivate func parseNewRoomMessagePayload(data: [String: Any]) {
        guard let messagePayload = data["message"] as? [String: Any] else {
            self.delegate?.error(eventType: .new_room_message, error: PCAPIEventError.keyNotPresentInPCAPIEventPayload(key: "message", apiEventType: .new_room_message, payload: data))
            return
        }

        guard let messageId = messagePayload["id"] as? Int,
              let messageSenderId = messagePayload["user_id"] as? Int,
              let messageRoomId = messagePayload["room_id"] as? Int,
              let messageText = messagePayload["text"] as? String,
              let messageCreatedAt = messagePayload["created_at"] as? String,
              let messageUpdatedAt = messagePayload["updated_at"] as? String
        else {
            self.delegate?.error(eventType: .new_room_message, error: PCAPIEventError.incompleteDataForKeyInPCAPIEventPayload(key: "message", apiEventType: .new_room_message, payload: messagePayload))
            return
        }

        let message = PCMessage(
            id: messageId,
            senderId: messageSenderId,
            roomId: messageRoomId,
            text: messageText,
            createdAt: messageCreatedAt,
            updatedAt: messageUpdatedAt
        )


        self.delegate?.messageReceived(roomId: messageRoomId, message: message)

        // TODO: This is what should actually be being called

//        self.delegate?.messageReceived(room: room, message: message)
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
