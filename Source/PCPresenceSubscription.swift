import PusherPlatform

public class PCPresenceSubscription {

    // TODO: Do we need to be careful of retain cycles here?

    let app: App
    public let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public internal(set) var delegate: PCChatManagerDelegate?

    public init(
        app: App,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        delegate: PCChatManagerDelegate? = nil
    ) {
        self.app = app
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.delegate = delegate
    }

    public func handleEvent(eventId: String, headers: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.app.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventNameString = json["event_name"] as? String else {
            self.app.logger.log("Event name missing for API event: \(json)", logLevel: .debug)
            return
        }

        guard let eventTypeString = json["event_type"] as? String else {
            self.app.logger.log("Event type missing for API event: \(json)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.app.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

        guard let eventName = PCPresenceEventName(rawValue: eventNameString) else {
            self.app.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        self.app.logger.log("Received event type: \(eventTypeString), event name: \(eventNameString), and data: \(apiEventData)", logLevel: .verbose)

        switch eventName {
        case .initial_state:
            parseInitialStatePayload(eventName, data: apiEventData, userStore: self.userStore)
        case .presence_update:
            parsePresenceUpdatePayload(eventName, data: apiEventData, userStore: self.userStore)
        }
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

            self.app.logger.log(error.localizedDescription, logLevel: .debug)
            self.delegate?.error(error: error)
            return
        }

        let userStates = userStatesPayload.flatMap { userStatePayload -> PCPresencePayload? in
            do {
                return try PCPayloadDeserializer.createPresencePayloadFromPayload(userStatePayload)
            } catch let err {
                self.app.logger.log(err.localizedDescription, logLevel: .debug)
                self.delegate?.error(error: err)
                return nil
            }
        }

        userStore.handleInitialPresencePayloads(userStates)
    }

    fileprivate func parsePresenceUpdatePayload(_ eventName: PCPresenceEventName, data: [String: Any], userStore: PCGlobalUserStore) {
        do {
            let presencePayload = try PCPayloadDeserializer.createPresencePayloadFromPayload(data)

            userStore.user(id: presencePayload.userId) { user, err in
                guard let user = user, err == nil else {
                    self.app.logger.log(
                        "Error fetching user information for user with id \(presencePayload.userId): \(err!.localizedDescription)",
                        logLevel: .debug
                    )
                    return
                }

                switch presencePayload.state {
                case .online:
                    self.delegate?.userCameOnline(user: user)
                case .offline:
                    self.delegate?.userWentOffline(user: user)
                case .unknown:
                    // This should never be the case
                    self.app.logger.log("Somehow the presence state of user \(user.debugDescription) is unknown", logLevel: .debug)
                    return
                }
            }
        } catch let err {
            self.app.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.error(error: err)
        }
    }

}

public enum PCPresenceEventName: String {
    case initial_state
    case presence_update
}

public enum PCPresenceEventError: Error {
    case keyNotPresentInEventPayload(key: String, apiEventName: PCPresenceEventName, payload: [String: Any])
}

extension PCPresenceEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .keyNotPresentInEventPayload(let key, let apiEventName, let payload):
            return "\(key) missing in \(apiEventName.rawValue) API event payload: \(payload)"
        }
    }
}
