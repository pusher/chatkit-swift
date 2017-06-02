import PusherPlatform

class PCBasicMessageEnricher {
    public let userStore: PCGlobalUserStore
    public let roomStore: PCRoomStore
    let logger: PPLogger

    fileprivate var completionOrderList: [Int] = []
    fileprivate var messageIdToCompletionHandlers: [Int: (PCMessage?, Error?) -> Void] = [:]
    fileprivate var enrichedMessagesAwaitingCompletionCalls: [Int: PCMessageEnrichmentResult] = [:]

    // TODO: What should the QoS be here?
    fileprivate let messageEnrichmentQueue = DispatchQueue(label: "com.pusher.chat-api.message-enrichment")

    init(userStore: PCGlobalUserStore, roomStore: PCRoomStore, logger: PPLogger) {
        self.userStore = userStore
        self.roomStore = roomStore
        self.logger = logger
    }

    func enrich(_ basicMessage: PCBasicMessage, completionHandler: @escaping (PCMessage?, Error?) -> Void) {
        let basicMessageId = basicMessage.id

        messageEnrichmentQueue.async(flags: .barrier) {
            self.completionOrderList.append(basicMessageId)
            self.messageIdToCompletionHandlers[basicMessageId] = completionHandler
        }

        self.userStore.user(id: basicMessage.senderId) { user, err in
            guard let user = user, err == nil else {
                self.logger.log(
                    "Unable to find user with id \(basicMessage.senderId), associated with message \(basicMessageId). Error: \(err!.localizedDescription)",
                    logLevel: .debug
                )
                self.callCompletionHandlersForEnrichedMessagesWithIdsLessThanOrEqualTo(id: basicMessageId, result: .error(err!))
                return
            }

            self.roomStore.room(id: basicMessage.roomId) { room, err in
                guard let room = room, err == nil else {
                    self.logger.log(
                        "Unable to find room with id \(basicMessage.roomId), associated with message \(basicMessageId). Error: \(err!.localizedDescription)",
                        logLevel: .debug
                    )
                    self.callCompletionHandlersForEnrichedMessagesWithIdsLessThanOrEqualTo(id: basicMessageId, result: .error(err!))
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

                self.callCompletionHandlersForEnrichedMessagesWithIdsLessThanOrEqualTo(id: basicMessageId, result: .success(message))
            }
        }
    }

    fileprivate func callCompletionHandlersForEnrichedMessagesWithIdsLessThanOrEqualTo(id: Int, result: PCMessageEnrichmentResult) {
        // TODO: There may well be ways to make this faster
        self.messageEnrichmentQueue.async(flags: .barrier) {
            guard let nextIdToComplete = self.completionOrderList.first else {
                self.logger.log("Message with id \(id) enriched but message enricher doesn't know about enriching it", logLevel: .debug)
                return
            }

            self.enrichedMessagesAwaitingCompletionCalls[id] = result

             guard id == nextIdToComplete else {
                // If the message id received isn't the next to have its completionHandler called
                // then return as we've already stored the result so it can be used later
                return
            }

            repeat {
                let messageId = self.completionOrderList.first!

                guard let completionHandler = self.messageIdToCompletionHandlers[messageId] else {
                    self.logger.log("Completion handler not stored for message id \(messageId)", logLevel: .debug)
                    return
                }

                guard let result = self.enrichedMessagesAwaitingCompletionCalls[messageId] else {
                    self.logger.log("Enrichment result not stored for message id \(messageId)", logLevel: .debug)
                    return
                }

                switch result {
                case .success(let message):
                    completionHandler(message, nil)
                case .error(let err):
                    completionHandler(nil, err)
                }

                self.completionOrderList.removeFirst()
                self.messageIdToCompletionHandlers.removeValue(forKey: messageId)
                self.enrichedMessagesAwaitingCompletionCalls.removeValue(forKey: messageId)
            } while self.completionOrderList.first != nil && self.enrichedMessagesAwaitingCompletionCalls[self.completionOrderList.first!] != nil
        }
    }
}

public enum PCMessageEnrichmentResult {
    case success(PCMessage)
    case error(Error)
}
