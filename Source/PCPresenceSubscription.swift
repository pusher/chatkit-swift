import Foundation
import PusherPlatform

public final class PCPresenceSubscription {

    // TODO: Do we need to be careful of retain cycles here? e.g. weak instance

    let instance: Instance
    public let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    public internal(set) var delegate: PCChatManagerDelegate?

    public init(
        instance: Instance,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        delegate: PCChatManagerDelegate? = nil
    ) {
        self.instance = instance
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.roomStore = roomStore
        self.delegate = delegate
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

        guard let eventName = PCPresenceEventName(rawValue: eventNameString) else {
            self.instance.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.instance.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

        self.instance.logger.log(
            "Received event name: \(eventNameString), and data: \(apiEventData)",
            logLevel: .verbose
        )

        switch eventName {
        case .initial_state:
            parseInitialStatePayload(eventName, data: apiEventData, userStore: self.userStore)
        case .presence_update:
            parsePresenceUpdatePayload(eventName, data: apiEventData, userStore: self.userStore)
        case .join_room_presence_update:
            parseJoinRoomPresenceUpdatePayload(eventName, data: apiEventData, userStore: self.userStore)
        }
    }

    func end() {
        self.resumableSubscription.end()
    }
}

extension PCPresenceSubscription {
    fileprivate func parseInitialStatePayload(_ eventName: PCPresenceEventName, data: [String: Any], userStore: PCGlobalUserStore) {
        guard let userStatesPayload = data["user_states"] as? [[String: Any]] else {
            let error = PCPresenceEventError.keyNotPresentInEventPayload(
                key: "user_states",
                apiEventName: eventName,
                payload: data
            )

            self.instance.logger.log(error.localizedDescription, logLevel: .debug)
            self.delegate?.error(error: error)
            return
        }

        let userStates = userStatesPayload.flatMap { userStatePayload -> PCPresencePayload? in
            do {
                return try PCPayloadDeserializer.createPresencePayloadFromPayload(userStatePayload)
            } catch let err {
                self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                self.delegate?.error(error: err)
                return nil
            }
        }

        guard userStates.count > 0 else {
            self.instance.logger.log("No presence user states to process", logLevel: .verbose)
            return
        }

        // TODO: Do we need [weak self] here?
        userStore.handleInitialPresencePayloads(userStates) { [weak self] in
            guard let strongSelf = self else {
                print("self is nil when handling initial presence payloads has completed")
                return
            }

            strongSelf.roomStore.rooms.forEach { room in
                room.subscription?.delegate?.usersUpdated()
                strongSelf.instance.logger.log("Users updated in room \(room.name)", logLevel: .verbose)
            }
        }
    }

    fileprivate func parsePresenceUpdatePayload(_: PCPresenceEventName, data: [String: Any], userStore: PCGlobalUserStore) {
        do {
            let presencePayload = try PCPayloadDeserializer.createPresencePayloadFromPayload(data)

            userStore.user(id: presencePayload.userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user when handling presence update event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.instance.logger.log(
                        "Error fetching user information for user with id \(presencePayload.userId): \(err!.localizedDescription)",
                        logLevel: .debug
                    )
                    return
                }

                user.updatePresenceInfoIfAppropriate(newInfoPayload: presencePayload)

                switch presencePayload.state {
                case .online:
                    strongSelf.delegate?.userCameOnline(user: user)
                    strongSelf.instance.logger.log("\(user.displayName) came online", logLevel: .verbose)
                case .offline:
                    strongSelf.delegate?.userWentOffline(user: user)
                    strongSelf.instance.logger.log("\(user.displayName) came offline", logLevel: .verbose)
                case .unknown:
                    // This should never be the case
                    strongSelf.instance.logger.log("Somehow the presence state of user \(user.debugDescription) is unknown", logLevel: .debug)
                    return
                }

                // TODO: Could check if any room is active to speed this up? Or keep a better
                // map of user_ids to rooms
                strongSelf.roomStore.rooms.forEach { room in
                    guard room.users.contains(user) else {
                        return
                    }

                    switch presencePayload.state {
                    case .online: room.subscription?.delegate?.userCameOnlineInRoom(user: user)
                    case .offline: room.subscription?.delegate?.userWentOfflineInRoom(user: user)
                    default: return
                    }
                }
            }
        } catch let err {
            self.instance.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(error: err)
        }
    }

    // TODO: So much duplication
    fileprivate func parseJoinRoomPresenceUpdatePayload(_ eventName: PCPresenceEventName, data: [String: Any], userStore: PCGlobalUserStore) {
        guard let userStatesPayload = data["user_states"] as? [[String: Any]] else {
            let error = PCPresenceEventError.keyNotPresentInEventPayload(
                key: "user_states",
                apiEventName: eventName,
                payload: data
            )

            self.instance.logger.log(error.localizedDescription, logLevel: .debug)
            self.delegate?.error(error: error)
            return
        }

        let userStates = userStatesPayload.flatMap { userStatePayload -> PCPresencePayload? in
            do {
                return try PCPayloadDeserializer.createPresencePayloadFromPayload(userStatePayload)
            } catch let err {
                self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                self.delegate?.error(error: err)
                return nil
            }
        }

        guard userStates.count > 0 else {
            self.instance.logger.log("No presence user states to process", logLevel: .verbose)
            return
        }

        // TODO: So much duplication
        userStore.handleInitialPresencePayloadsAfterRoomJoin(userStates) {
            self.roomStore.rooms.forEach { room in
                room.subscription?.delegate?.usersUpdated()
                self.instance.logger.log("Users updated " + room.users.map { "\($0.id), \($0.name ?? ""), \($0.presenceState.rawValue)" }.joined(separator: "; "), logLevel: .verbose)
            }
        }
    }
}

public enum PCPresenceEventName: String {
    case initial_state
    case presence_update
    case join_room_presence_update
}

public enum PCPresenceEventError: Error {
    case keyNotPresentInEventPayload(key: String, apiEventName: PCPresenceEventName, payload: [String: Any])
}

extension PCPresenceEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .keyNotPresentInEventPayload(key, apiEventName, payload):
            return "\(key) missing in \(apiEventName.rawValue) API event payload: \(payload)"
        }
    }
}
