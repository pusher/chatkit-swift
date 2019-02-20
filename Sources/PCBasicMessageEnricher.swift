import Foundation
import PusherPlatform

final class PCBasicMessageEnricher<A: PCCommonBasicMessage, B: PCEnrichedMessage> {
    public let userStore: PCGlobalUserStore
    public let room: PCRoom
    let logger: PPLogger
    let messageFactory: (A, PCRoom, PCUser) -> B

    fileprivate var completionOrderList: [Int] = []
    fileprivate var messageIDToCompletionHandlers: [Int: (B?, Error?) -> Void] = [:]
    fileprivate var enrichedMessagesAwaitingCompletionCalls: [Int: PCMessageEnrichmentResult] = [:]
    fileprivate let messageEnrichmentQueue = DispatchQueue(label: "com.pusher.chatkit.message-enrichment-\(UUID().uuidString)")

    fileprivate var userIDsBeingRetrieved: [String] = []
    fileprivate var userIDsToBasicMessageIDs: [String: [Int]] = [:]
    fileprivate var messagesAwaitingEnrichmentDependentOnUserRetrieval: [Int: A] = [:]
    fileprivate let userRetrievalQueue = DispatchQueue(label: "com.pusher.chatkit.user-retrieval-\(UUID().uuidString)")
    
    init(
        userStore: PCGlobalUserStore,
        room: PCRoom,
        messageFactory: @escaping (A, PCRoom, PCUser) -> B,
        logger: PPLogger
    ) {
        self.userStore = userStore
        self.room = room
        self.logger = logger
        self.messageFactory = messageFactory
    }

    func enrich(_ basicMessage: A, completionHandler: @escaping (B?, Error?) -> Void) {
        let basicMessageID = basicMessage.id
        let basicMessageSenderID = basicMessage.senderID

        messageEnrichmentQueue.async(flags: .barrier) {
            self.completionOrderList.append(basicMessageID)
            self.messageIDToCompletionHandlers[basicMessageID] = completionHandler
        }

        userRetrievalQueue.async(flags: .barrier) {
            if self.userIDsToBasicMessageIDs[basicMessageSenderID] == nil {
                self.userIDsToBasicMessageIDs[basicMessageSenderID] = [basicMessageID]
            } else {
                self.userIDsToBasicMessageIDs[basicMessageSenderID]!.append(basicMessageID)
            }

            self.messagesAwaitingEnrichmentDependentOnUserRetrieval[basicMessageID] = basicMessage

            if self.userIDsBeingRetrieved.contains(basicMessageSenderID) {
                return
            } else {
                self.userIDsBeingRetrieved.append(basicMessageSenderID)
            }

            self.userStore.user(id: basicMessage.senderID) { [weak self] user, err in
                guard let strongSelf = self else {
                    print("self is nil when user store returns user while enriching messages")
                    return
                }

                guard let user = user, err == nil else {
                    strongSelf.logger.log(
                        "Unable to find user with id \(basicMessage.senderID), associated with message \(basicMessageID). Error: \(err!.localizedDescription)",
                        logLevel: .debug
                    )
                    strongSelf.callCompletionHandlersForEnrichedMessagesWithIDsLessThanOrEqualTo(id: basicMessageID, result: .error(err!))
                    return
                }

                strongSelf.userRetrievalQueue.async(flags: .barrier) {
                    guard let basicMessageIDs = strongSelf.userIDsToBasicMessageIDs[basicMessageSenderID] else {
                        strongSelf.logger.log(
                            "Fetched user information for user with id \(user.id) but no messages needed information for this user",
                            logLevel: .verbose
                        )
                        return
                    }

                    let basicMessages = basicMessageIDs.compactMap { bmID -> A? in
                        return strongSelf.messagesAwaitingEnrichmentDependentOnUserRetrieval[bmID]
                    }

                    strongSelf.enrichMessagesWithUser(user, messages: basicMessages)

                    if let indexToRemove = strongSelf.userIDsBeingRetrieved.index(of: basicMessageSenderID) {
                        strongSelf.userIDsBeingRetrieved.remove(at: indexToRemove)
                    }
                }
            }
        }
    }

    fileprivate func enrichMessagesWithUser(_ user: PCUser, messages: [A]) {
        messages.forEach { basicMessage in
            let message = self.messageFactory(basicMessage, room, user)
            self.callCompletionHandlersForEnrichedMessagesWithIDsLessThanOrEqualTo(id: basicMessage.id, result: PCMessageEnrichmentResult.success(message))
        }
    }

    fileprivate func callCompletionHandlersForEnrichedMessagesWithIDsLessThanOrEqualTo(id: Int, result: PCMessageEnrichmentResult) {

        // TODO: There may well be ways to make this faster
        self.messageEnrichmentQueue.async(flags: .barrier) {
            guard let nextIDToComplete = self.completionOrderList.first else {
                self.logger.log("Message with id \(id) enriched but message enricher doesn't know about enriching it", logLevel: .debug)
                return
            }

            self.enrichedMessagesAwaitingCompletionCalls[id] = result

            guard id == nextIDToComplete else {
                // If the message id received isn't the next to have its completionHandler called
                // then return as we've already stored the result so it can be used later
                self.logger.log(
                    "Waiting to call completion handler for message id \(id) as there are other older messages still to be enriched",
                    logLevel: .verbose
                )
                return
            }

            repeat {
                let messageID = self.completionOrderList.first!

                guard let completionHandler = self.messageIDToCompletionHandlers[messageID] else {
                    self.logger.log("Completion handler not stored for message id \(messageID)", logLevel: .debug)
                    return
                }

                guard let result = self.enrichedMessagesAwaitingCompletionCalls[messageID] else {
                    self.logger.log("Enrichment result not stored for message id \(messageID)", logLevel: .debug)
                    return
                }

                switch result {
                case let .success(message):
                    completionHandler(message, nil)
                case let .error(err):
                    completionHandler(nil, err)
                }

                self.completionOrderList.removeFirst()
                self.messageIDToCompletionHandlers.removeValue(forKey: messageID)
                self.enrichedMessagesAwaitingCompletionCalls.removeValue(forKey: messageID)
            } while self.completionOrderList.first != nil && self.enrichedMessagesAwaitingCompletionCalls[self.completionOrderList.first!] != nil
        }
    }
    
    enum PCMessageEnrichmentResult {
        case success(B)
        case error(Error)
    }
}

