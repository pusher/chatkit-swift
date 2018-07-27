import Foundation
import PusherPlatform

public final class PCMembershipSubscription {
    public weak var delegate: PCRoomDelegate?
    let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    public var logger: PPLogger
    var initialStateHandler: (Error?) -> Void
    weak var chatManagerDelegate: PCChatManagerDelegate?

    let roomId: Int

    init(
        roomId: Int,
        delegate: PCRoomDelegate? = nil,
        chatManagerDelegate: PCChatManagerDelegate? = nil,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        logger: PPLogger,
        initialStateHandler: @escaping (Error?) -> Void
    ) {
        self.roomId = roomId
        self.delegate = delegate
        self.chatManagerDelegate = chatManagerDelegate
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.roomStore = roomStore
        self.logger = logger
        self.initialStateHandler = initialStateHandler
    }

    func handleEvent(eventId _: String, headers _: [String: String], data: Any) {
        guard let json = data as? [String: Any] else {
            self.logger.log("Failed to cast JSON object to Dictionary: \(data)", logLevel: .debug)
            return
        }

        guard let eventNameString = json["event_name"] as? String else {
            self.logger.log("Event name missing for API event: \(json)", logLevel: .debug)
            return
        }

        guard let eventName = PCMembershipEventName(rawValue: eventNameString) else {
            self.logger.log("Unsupported API event name received: \(eventNameString)", logLevel: .debug)
            return
        }

        guard let apiEventData = json["data"] as? [String: Any] else {
            self.logger.log("Data missing for API event: \(json)", logLevel: .debug)
            return
        }

        self.logger.log(
            "Received event name: \(eventNameString), and data: \(apiEventData)",
            logLevel: .verbose
        )

        switch eventName {
        case .initial_state:
            parseInitialStatePayload(eventName, data: apiEventData)
        case .user_joined:
            parseUserJoinedPayload(eventName, data: apiEventData)
        case .user_left:
            parseUserLeftPayload(eventName, data: apiEventData)
        }
    }

    func end() {
        self.resumableSubscription.end()
    }
}

extension PCMembershipSubscription {

    fileprivate func parseInitialStatePayload(
        _ eventName: PCMembershipEventName,
        data: [String: Any]
    ) {
        guard let userIds = data["user_ids"] as? [String] else {
            self.logger.log(
                "user_states key not present in initial_state payload",
                logLevel: .error
            )
            return
        }

        self.roomStore.room(id: roomId) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user after parsing initial state event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.initialStateHandler(err!)
                return
            }

            strongSelf.userStore.fetchUsersWithIds(Set<String>(userIds)) { [weak self] users, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing initial state event")
                    return
                }

                guard let users = users, err == nil else {
                    strongSelf.initialStateHandler(err!)
                    return
                }

                users.forEach { user in
                    let addedOrMergedUser = room.userStore.addOrMerge(user)
                    room.userIds.insert(addedOrMergedUser.id)
                }

                strongSelf.initialStateHandler(nil)
            }
        }
    }

    fileprivate func parseUserJoinedPayload(
        _ eventName: PCMembershipEventName,
        data: [String: Any]
    ) {
        guard let userId = data["user_id"] as? String else {
            self.logger.log(
                "user_id key not present in user_joined payload",
                logLevel: .error
            )
            return
        }

        self.roomStore.room(id: roomId) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user after parsing user joined event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.logger.log(
                    "User with id \(userId) joined room with id \(strongSelf.roomId) but no information about the room could be retrieved. Error was: \(err!.localizedDescription)",
                    logLevel: .error
                )
                return
            }

            strongSelf.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing user joined event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(
                        "User with id \(userId) joined room with id \(strongSelf.roomId) but no information about the user could be retrieved. Error was: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    return
                }

                let addedOrMergedUser = room.userStore.addOrMerge(user)
                room.userIds.insert(addedOrMergedUser.id)

                strongSelf.delegate?.userJoined(user: addedOrMergedUser)
                strongSelf.chatManagerDelegate?.userJoinedRoom(room: room, user: user)
                strongSelf.logger.log("User \(user.displayName) joined room: \(room.name)", logLevel: .verbose)
            }
        }
    }

    fileprivate func parseUserLeftPayload(
        _ eventName: PCMembershipEventName,
        data: [String: Any]
    ) {
        guard let userId = data["user_id"] as? String else {
            self.logger.log(
                "user_id key not present in user_left payload",
                logLevel: .error
            )
            return
        }

        self.roomStore.room(id: roomId) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user after parsing user left event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.logger.log(
                    "User with id \(userId) left room with id \(strongSelf.roomId) but no information about the room could be retrieved. Error was: \(err!.localizedDescription)",
                    logLevel: .error
                )
                return
            }

            strongSelf.userStore.user(id: userId) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing user left event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(
                        "User with id \(userId) left room with id \(strongSelf.roomId) but no information about the user could be retrieved. Error was: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    return
                }

                let roomUserIdIndex = room.userIds.index(of: user.id)

                if let indexToRemove = roomUserIdIndex {
                    room.userIds.remove(at: indexToRemove)
                }

                room.userStore.remove(id: user.id)

                strongSelf.delegate?.userLeft(user: user)
                strongSelf.chatManagerDelegate?.userLeftRoom(room: room, user: user)
                strongSelf.logger.log("User \(user.displayName) left room: \(room.name)", logLevel: .verbose)
            }
        }
    }

}

public enum PCMembershipEventName: String {
    case initial_state
    case user_joined
    case user_left
}
