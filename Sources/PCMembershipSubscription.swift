import Foundation
import PusherPlatform

public final class PCMembershipSubscription {
    let resumableSubscription: PPResumableSubscription
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    public var logger: PPLogger
    let onUserJoinedHook: (PCUser) -> Void
    let onUserLeftHook: (PCUser) -> Void
    var initialStateHandler: (InitialStateResult<PCUser>) -> Void

    let roomID: String

    init(
        roomID: String,
        resumableSubscription: PPResumableSubscription,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        logger: PPLogger,
        onUserJoinedHook: @escaping (PCUser) -> Void,
        onUserLeftHook: @escaping (PCUser) -> Void,
        initialStateHandler: @escaping (InitialStateResult<PCUser>) -> Void
    ) {
        self.roomID = roomID
        self.resumableSubscription = resumableSubscription
        self.userStore = userStore
        self.roomStore = roomStore
        self.logger = logger
        self.onUserJoinedHook = onUserJoinedHook
        self.onUserLeftHook = onUserLeftHook
        self.initialStateHandler = initialStateHandler
    }

    func handleEvent(eventID _: String, headers _: [String: String], data: Any) {
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
        guard let userIDs = data["user_ids"] as? [String] else {
            self.logger.log(
                "user_states key not present in initial_state payload",
                logLevel: .error
            )
            return
        }

        self.roomStore.room(id: roomID) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user after parsing initial state event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.initialStateHandler(.error(err!))
                return
            }

            strongSelf.userStore.fetchUsersWithIDs(Set<String>(userIDs)) { [weak self] users, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing initial state event")
                    return
                }

                guard let users = users, err == nil else {
                    strongSelf.initialStateHandler(.error(err!))
                    return
                }

                let existingUsers = room.userStore.users.map { $0.copy() }

                let oldSet = Set(existingUsers)
                let newSet = Set(users)
                let membersRemoved = oldSet.subtracting(newSet)

                users.forEach { user in
                    let addedOrMergedUser = room.userStore.addOrMerge(user)
                    room.userIDs.insert(addedOrMergedUser.id)
                }

                membersRemoved.forEach { m in
                    room.userStore.remove(id: m.id)
                }

                strongSelf.initialStateHandler(.success(existing: existingUsers, new: users))
            }
        }
    }

    fileprivate func parseUserJoinedPayload(
        _ eventName: PCMembershipEventName,
        data: [String: Any]
    ) {
        guard let userID = data["user_id"] as? String else {
            self.logger.log(
                "user_id key not present in user_joined payload",
                logLevel: .error
            )
            return
        }

        self.roomStore.room(id: roomID) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user after parsing user joined event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.logger.log(
                    "User with id \(userID) joined room with id \(strongSelf.roomID) but no information about the room could be retrieved. Error was: \(err!.localizedDescription)",
                    logLevel: .error
                )
                return
            }

            strongSelf.userStore.user(id: userID) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing user joined event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(
                        "User with id \(userID) joined room with id \(strongSelf.roomID) but no information about the user could be retrieved. Error was: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    return
                }

                let addedOrMergedUser = room.userStore.addOrMerge(user)
                room.userIDs.insert(addedOrMergedUser.id)

                strongSelf.onUserJoinedHook(user)
                strongSelf.logger.log("User \(user.displayName) joined room: \(room.name)", logLevel: .verbose)
            }
        }
    }

    fileprivate func parseUserLeftPayload(
        _ eventName: PCMembershipEventName,
        data: [String: Any]
    ) {
        guard let userID = data["user_id"] as? String else {
            self.logger.log(
                "user_id key not present in user_left payload",
                logLevel: .error
            )
            return
        }

        self.roomStore.room(id: roomID) { [weak self] room, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user after parsing user left event")
                return
            }

            guard let room = room, err == nil else {
                strongSelf.logger.log(
                    "User with id \(userID) left room with id \(strongSelf.roomID) but no information about the room could be retrieved. Error was: \(err!.localizedDescription)",
                    logLevel: .error
                )
                return
            }

            strongSelf.userStore.user(id: userID) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user after parsing user left event")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(
                        "User with id \(userID) left room with id \(strongSelf.roomID) but no information about the user could be retrieved. Error was: \(err!.localizedDescription)",
                        logLevel: .error
                    )
                    return
                }

                room.removeUser(id: user.id)

                strongSelf.onUserLeftHook(user)
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
