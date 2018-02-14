import Foundation
import PusherPlatform

final class PCBasicCursorEnricher {
    public let userStore: PCGlobalUserStore
    public let room: PCRoom
    let logger: PPLogger

    init(userStore: PCGlobalUserStore, room: PCRoom, logger: PPLogger) {
        self.userStore = userStore
        self.room = room
        self.logger = logger
    }

    func enrich(_ basicCursor: PCBasicCursor, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        self.userStore.user(id: basicCursor.userId) { [weak self] user, err in
            guard let strongSelf = self else {
                print("self is nil when user store returns user while enriching cursor")
                return
            }

            guard let user = user, err == nil else {
                strongSelf.logger.log(
                    "Unable to find user with id \(basicCursor.userId) while enriching cursor. Error: \(err!.localizedDescription)",
                    logLevel: .debug
                )
                completionHandler(nil, err!)
                return
            }

            let cursor = PCCursor(
                type: basicCursor.type,
                position: basicCursor.position,
                room: strongSelf.room,
                updatedAt: basicCursor.updatedAt,
                user: user
            )

            completionHandler(cursor, nil)
        }
    }
}
