import Foundation
import PusherPlatform

final class PCBasicCursorEnricher {
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    let logger: PPLogger

    init(userStore: PCGlobalUserStore, roomStore: PCRoomStore, logger: PPLogger) {
        self.userStore = userStore
        self.roomStore = roomStore
        self.logger = logger
    }

    func enrich(_ basicCursor: PCBasicCursor, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        self.userStore.user(id: basicCursor.userID) { [weak self] user, userErr in
            guard let strongSelf = self else {
                print("self is nil when user store returns user while enriching cursor")
                return
            }

            guard let user = user, userErr == nil else {
                strongSelf.logger.log(
                    "Unable to find user with id \(basicCursor.userID) while enriching cursor. Error: \(userErr!.localizedDescription)",
                    logLevel: .debug
                )
                completionHandler(nil, userErr!)
                return
            }

            strongSelf.roomStore.room(id: basicCursor.roomID) { [weak self] room, roomErr in
                guard let strongSelf = self else {
                    print("self is nil when room store returns room while enriching cursor")
                    return
                }

                guard let room = room, roomErr == nil else {
                    strongSelf.logger.log(
                        "Unable to find user with id \(basicCursor.userID) while enriching cursor. Error: \(roomErr!.localizedDescription)",
                        logLevel: .debug
                    )
                    completionHandler(nil, roomErr!)
                    return
                }

                let cursor = PCCursor(
                    type: basicCursor.type,
                    position: basicCursor.position,
                    room: room,
                    updatedAt: basicCursor.updatedAt,
                    user: user
                )

                completionHandler(cursor, nil)
            }
        }
    }
}
