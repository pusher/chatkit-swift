import Foundation
import PusherPlatform

public final class PCUserPresenceSubscription {
    public let userID: String
    public let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    public internal(set) weak var delegate: PCChatManagerDelegate?
    public var logger: PCLogger

    public init(
        userID: String,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        logger: PCLogger,
        delegate: PCChatManagerDelegate? = nil
    ) {
        self.userID = userID
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.roomStore = roomStore
        self.delegate = delegate
        self.logger = logger
    }

    public func handleEvent(eventID _: String, headers _: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventNameString = json["event_name"] as? String else {
            self.logger.log("Event name missing for API event: \(json)", logLevel: .debug)
            return
        }

        guard let eventName = PCUserPresenceEventName(rawValue: eventNameString) else {
            self.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

        self.logger.log(
            "Received event name: \(eventNameString), for user ID: \(self.userID), with data: \(apiEventData)",
            logLevel: .verbose
        )

        switch eventName {
        case .presence_state:
            parsePresenceStatePayload(eventName, data: apiEventData)
        }
    }

    func end() {
        self.resumableSubscription.end()
    }
}

extension PCUserPresenceSubscription {
    fileprivate func parsePresenceStatePayload(_ eventName: PCUserPresenceEventName, data: [String: Any]) {
        do {
            let presencePayload = try PCPayloadDeserializer.createPresencePayloadFromPayload(data)

            self.userStore.user(id: self.userID) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user when handling presence state event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(
                        "Error fetching user information for user with id \(strongSelf.userID): \(err!.localizedDescription)",
                        logLevel: .debug
                    )
                    return
                }

                let previousPresenceState = user.presenceState
                user.updatePresenceInfoIfAppropriate(newInfoPayload: presencePayload)

                switch presencePayload.state {
                case .online:
                    strongSelf.logger.log("\(user.displayName) came online", logLevel: .verbose)
                case .offline:
                    strongSelf.logger.log("\(user.displayName) went offline", logLevel: .verbose)
                case .unknown:
                    // This should never be the case
                    strongSelf.logger.log(
                        "Somehow the presence state of user \(user.debugDescription) is unknown",
                        logLevel: .debug
                    )
                }

                strongSelf.delegate?.onPresenceChanged(
                    stateChange: PCPresenceStateChange(
                        previous: previousPresenceState,
                        current: presencePayload.state
                    ),
                    user: user
                )

                // TODO: Could check if any room is active to speed this up? Or keep a better
                // map of user_ids to rooms
                strongSelf.roomStore.rooms.forEach { room in
                    guard room.users.contains(user) else {
                        return
                    }

                    room.subscription?.delegate?.onPresenceChanged(
                        stateChange: PCPresenceStateChange(
                            previous: previousPresenceState,
                            current: presencePayload.state
                        ),
                        user: user
                    )
                }
            }
        } catch let err {
            self.logger.log(err.localizedDescription, logLevel: .debug)
            self.delegate?.onError(error: err)
        }
    }
}

public enum PCUserPresenceEventName: String {
    case presence_state
}
