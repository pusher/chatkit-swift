import PusherPlatform

class PCBasicMessageEnricher {
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    let logger: PPLogger

    init(userStore: PCGlobalUserStore, roomStore: PCRoomStore, logger: PPLogger) {
        self.userStore = userStore
        self.roomStore = roomStore
        self.logger = logger
    }

    func enrich(_ basicMessage: PCBasicMessage, completionHandler: @escaping (PCMessage?, Error?) -> Void) {
        self.userStore.user(id: basicMessage.senderId) { user, err in
            guard let user = user, err == nil else {
                self.logger.log(
                    "Unable to find user with id \(basicMessage.senderId), associated with message \(basicMessage.id). Error: \(err!.localizedDescription)",
                    logLevel: .debug
                )
                completionHandler(nil, err!)
                return
            }

            self.roomStore.room(id: basicMessage.roomId) { room, err in
                guard let room = room, err == nil else {
                    self.logger.log(
                        "Unable to find room with id \(basicMessage.roomId), associated with message \(basicMessage.id). Error: \(err!.localizedDescription)",
                        logLevel: .debug
                    )
                    completionHandler(nil, err!)
                    return
                }

                let message = PCMessage(
                    id: basicMessage.id,
                    text: basicMessage.text,
                    createdAt: basicMessage.createdAt,
                    updatedAt: basicMessage.updatedAt,
                    sender: user,
                    room: room
                )

                completionHandler(message, nil)
            }
        }
    }

}
