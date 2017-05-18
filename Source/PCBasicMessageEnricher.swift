class PCBasicMessageEnricher {
    public let userStore: PCUserStore
    public let roomStore: PCRoomStore

    init(userStore: PCUserStore, roomStore: PCRoomStore) {
        self.userStore = userStore
        self.roomStore = roomStore
    }

    func enrich(_ basicMessage: PCBasicMessage, completionHandler: @escaping (PCMessage?, Error?) -> Void) {
        self.userStore.user(id: basicMessage.senderId) { user, err in
            guard let user = user, err == nil else {
                // TODO: Logging

                completionHandler(nil, err!)
                return
            }

            self.roomStore.room(id: basicMessage.roomId) { room, err in
                guard let room = room, err == nil else {
                    // TODO: Logging

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
