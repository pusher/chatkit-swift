import Foundation
import PusherPlatform

public final class PCRoomSubscription {
    public var messageSubscription: PCMessageSubscription<PCBasicMessage, PCMessage>?
    public var multipartMessageSubscription: PCMessageSubscription<PCBasicMultipartMessage, PCMultipartMessage>?
    public var cursorSubscription: PCCursorSubscription?
    public var membershipSubscription: PCMembershipSubscription?
    public weak var delegate: PCRoomDelegate?
    public var version: String
    weak var room: PCRoom?

    fileprivate let eventBufferQueue = DispatchQueue(label: "com.pusher.chatkit.room-event-buffer-\(UUID().uuidString)")
    var eventBuffer = [() -> Void]()

    init(
        room: PCRoom,
        messageLimit: Int,
        currentUserID: String,
        roomDelegate: PCRoomDelegate,
        chatManagerDelegate: PCChatManagerDelegate,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        cursorStore: PCCursorStore,
        typingIndicatorManager: PCTypingIndicatorManager,
        instance: Instance,
        cursorsInstance: Instance,
        version: String,
        logger: PCLogger,
        completionHandler: @escaping PCErrorCompletionHandler
    ) {
        self.delegate = roomDelegate
        self.room = room
        self.version = version

        let progressCounter = PCProgressCounter(
            totalCount: 3,
            labelSuffix: "subscribe-to-room-\(UUID().uuidString)"
        )

        let combinedCompletionHandler = { [logger = logger, weak room, weak self] (err: Error?) in
            guard err == nil else {
                logger.log(
                    "Error when establishing room subscription: \(err!.localizedDescription)",
                    logLevel: .error
                )
                if progressCounter.incrementFailedAndCheckIfFinished() {
                    completionHandler(err)
                }
                return
            }
            if progressCounter.incrementSuccessAndCheckIfFinished() {
                self?.eventBufferQueue.async {
                    room?.subscriptionPreviouslyEstablished = true
                    completionHandler(nil)
                    self?.eventBuffer.forEach { $0() }
                    self?.eventBuffer = []
                }
            }
        }
        
        if version == "v6" {
            self.multipartMessageSubscription = subscribeToRoomMultipartMessages(
                room: room,
                messageLimit: messageLimit,
                instance: instance,
                userStore: userStore,
                roomStore: roomStore,
                logger: logger,
                urlRefresher: PCMultipartAttachmentUrlRefresher(client: instance),
                onMessageHook: { [weak roomDelegate, weak self] message in
                    instance.logger.log("Room received new message: \(message.debugDescription)", logLevel: .verbose)
                    self?.eventBufferQueue.async {
                        self?.callOrBuffer(room: room) {
                            roomDelegate?.onMultipartMessage(message)
                        }
                    }
                },
                onIsTypingHook: { [weak typingIndicatorManager, weak roomDelegate, weak cmDelegate = chatManagerDelegate, weak self] room, user in
                    self?.eventBufferQueue.async {
                        self?.callOrBuffer(room: room) {
                            typingIndicatorManager?.onIsTyping(
                                room: room,
                                user: user,
                                globalStartHook: cmDelegate?.onUserStartedTyping,
                                globalStopHook: cmDelegate?.onUserStoppedTyping,
                                roomStartHook: roomDelegate?.onUserStartedTyping,
                                roomStopHook: roomDelegate?.onUserStoppedTyping
                            )
                        }
                    }
                },
                onMessageDeletedHook: { [weak roomDelegate, weak self] messageID in
                    instance.logger.log("Room received message_deleted event: \(messageID)", logLevel: .verbose)
                    self?.eventBufferQueue.async {
                        self?.callOrBuffer(room: room) {
                            roomDelegate?.onMessageDeleted(messageID)
                        }
                    }
                },
                completionHandler: combinedCompletionHandler
            )
            self.messageSubscription = nil
        } else {
            self.messageSubscription = subscribeToRoomMessages(
                room: room,
                messageLimit: messageLimit,
                instance: instance,
                userStore: userStore,
                roomStore: roomStore,
                logger: logger,
                onMessageHook: { [weak roomDelegate, weak self] message in
                    instance.logger.log("Room received new message: \(message.debugDescription)", logLevel: .verbose)
                    self?.eventBufferQueue.async {
                        self?.callOrBuffer(room: room) {
                            roomDelegate?.onMessage(message)
                        }
                    }
                },
                onIsTypingHook: { [weak typingIndicatorManager, weak roomDelegate, weak cmDelegate = chatManagerDelegate, weak self] room, user in
                    self?.eventBufferQueue.async {
                        self?.callOrBuffer(room: room) {
                            typingIndicatorManager?.onIsTyping(
                                room: room,
                                user: user,
                                globalStartHook: cmDelegate?.onUserStartedTyping,
                                globalStopHook: cmDelegate?.onUserStoppedTyping,
                                roomStartHook: roomDelegate?.onUserStartedTyping,
                                roomStopHook: roomDelegate?.onUserStoppedTyping
                            )
                        }
                    }
                },
                onMessageDeletedHook: { _ in }, // message_deleted is not sent over v2
                completionHandler: combinedCompletionHandler
            )
            self.multipartMessageSubscription = nil
        }
        
        let cursorSub = subscribeToRoomCursors(
            room: room,
            cursorsInstance: cursorsInstance,
            cursorStore: cursorStore,
            logger: logger,
            onNewReadCursorHook: { [currentUserID = currentUserID, weak cmDelegate = chatManagerDelegate, weak roomDelegate, weak self] cursor in
                self?.eventBufferQueue.async {
                    self?.callOrBuffer(room: room) {
                        roomDelegate?.onNewReadCursor(cursor)
                        if cursor.user.id == currentUserID {
                            cmDelegate?.onNewReadCursor(cursor)
                        }
                    }
                }
            },
            completionHandler: combinedCompletionHandler
        )

        let membershipSub = subscribeToRoomMemberships(
            room: room,
            instance: instance,
            userStore: userStore,
            roomStore: roomStore,
            logger: logger,
            onUserJoinedHook: { [weak cmDelegate = chatManagerDelegate, weak roomDelegate, weak self] user in
                self?.eventBufferQueue.async {
                    self?.callOrBuffer(room: room) {
                        cmDelegate?.onUserJoinedRoom(room, user: user)
                        roomDelegate?.onUserJoined(user: user)
                    }
                }
            },
            onUserLeftHook: { [weak cmDelegate = chatManagerDelegate, weak roomDelegate, weak self] user in
                self?.eventBufferQueue.async {
                    self?.callOrBuffer(room: room) {
                        cmDelegate?.onUserLeftRoom(room, user: user)
                        roomDelegate?.onUserLeft(user: user)
                    }
                }
            },
            completionHandler: combinedCompletionHandler
        )

        self.cursorSubscription = cursorSub
        self.membershipSubscription = membershipSub
    }

    func end() {
        if self.messageSubscription != nil {
            self.messageSubscription!.end()
        }
        
        if self.multipartMessageSubscription != nil {
            self.multipartMessageSubscription!.end()
        }
    
        self.cursorSubscription?.end()
        self.membershipSubscription?.end()

        self.messageSubscription = nil
        self.multipartMessageSubscription = nil
        self.cursorSubscription = nil
        self.membershipSubscription = nil
    }

    func callOrBuffer(room: PCRoom, eventHook: @escaping () -> Void) {
        if room.subscriptionPreviouslyEstablished {
            eventHook()
        } else {
            self.eventBuffer.append {
                eventHook()
            }
        }
    }
}

fileprivate func subscribeToRoomMessages(
    room: PCRoom,
    messageLimit: Int,
    instance: Instance,
    userStore: PCGlobalUserStore,
    roomStore: PCRoomStore,
    logger: PCLogger,
    onMessageHook: @escaping (PCMessage) -> Void,
    onIsTypingHook: @escaping (PCRoom, PCUser) -> Void,
    onMessageDeletedHook: @escaping (Int) -> Void,
    completionHandler: @escaping PCErrorCompletionHandler
) -> PCMessageSubscription<PCBasicMessage, PCMessage> {
    let path = "/rooms/\(room.id)"

    // TODO: What happens if you provide both a message_limit and a Last-Event-ID?
    let subscribeRequest = PPRequestOptions(
        method: HTTPMethod.SUBSCRIBE.rawValue,
        path: path,
        queryItems: [
            URLQueryItem(name: "message_limit", value: String(messageLimit))
        ]
    )

    var resumableSub = PPResumableSubscription(
        instance: instance,
        requestOptions: subscribeRequest
    )

    let messageSubscription = PCMessageSubscription(
        roomID: room.id,
        resumableSubscription: resumableSub,
        logger: logger,
        basicMessageEnricher: PCBasicMessageEnricher<PCBasicMessage, PCMessage>(
            userStore: userStore,
            room: room,
            messageFactory: { (basicMessage, room, user) in
                return PCMessage(
                    id: basicMessage.id,
                    text: basicMessage.text,
                    createdAt: basicMessage.createdAt,
                    updatedAt: basicMessage.updatedAt,
                    deletedAt: basicMessage.deletedAt,
                    attachment: basicMessage.attachment,
                    sender: user,
                    room: room
                )
            },
            logger: logger
        ),
        deserialise: PCPayloadDeserializer.createBasicMessageFromPayload,
        userStore: userStore,
        roomStore: roomStore,
        onMessageHook: onMessageHook,
        onIsTypingHook: onIsTypingHook,
        onMessageDeletedHook: onMessageDeletedHook
    )

    instance.subscribeWithResume(
        with: &resumableSub,
        using: subscribeRequest,
        onOpen: { completionHandler(nil) },
        onEvent: { [unowned messageSubscription] eventID, headers, data in
            messageSubscription.handleEvent(eventID: eventID, headers: headers, data: data)
        },
        onError: completionHandler
    )

    return messageSubscription
}

fileprivate func subscribeToRoomMultipartMessages(
    room: PCRoom,
    messageLimit: Int,
    instance: Instance,
    userStore: PCGlobalUserStore,
    roomStore: PCRoomStore,
    logger: PCLogger,
    urlRefresher: PCMultipartAttachmentUrlRefresher,
    onMessageHook: @escaping (PCMultipartMessage) -> Void,
    onIsTypingHook: @escaping (PCRoom, PCUser) -> Void,
    onMessageDeletedHook: @escaping (Int) -> Void,
    completionHandler: @escaping PCErrorCompletionHandler
    ) -> PCMessageSubscription<PCBasicMultipartMessage, PCMultipartMessage> {
    let path = "/rooms/\(room.id)"
    
    let subscribeRequest = PPRequestOptions(
        method: HTTPMethod.SUBSCRIBE.rawValue,
        path: path,
        queryItems: [
            URLQueryItem(name: "message_limit", value: String(messageLimit))
        ]
    )

    var resumableSub = PPResumableSubscription(instance: instance, requestOptions: subscribeRequest)
    
    let messageSubscription = PCMessageSubscription<PCBasicMultipartMessage, PCMultipartMessage>(
        roomID: room.id,
        resumableSubscription: resumableSub,
        logger: logger,
        basicMessageEnricher: PCBasicMessageEnricher<PCBasicMultipartMessage, PCMultipartMessage>(
            userStore: userStore,
            room: room,
            messageFactory: { (basicMessage, room, user) in
                return PCMultipartMessage(
                    id: basicMessage.id,
                    sender: user,
                    room: room,
                    parts: basicMessage.parts,
                    createdAt: basicMessage.createdAt,
                    updatedAt: basicMessage.updatedAt
                )
            },
            logger: logger
        ),
        deserialise: { rawPayload in
            return try PCPayloadDeserializer.createMultipartMessageFromPayload(
                rawPayload,
                urlRefresher: urlRefresher
            )
        },
        userStore: userStore,
        roomStore: roomStore,
        onMessageHook: onMessageHook,
        onIsTypingHook: onIsTypingHook,
        onMessageDeletedHook: onMessageDeletedHook
    )
    
    instance.subscribeWithResume(
        with: &resumableSub,
        using: subscribeRequest,
        onOpen: { completionHandler(nil) },
        onEvent: { [unowned messageSubscription] eventID, headers, data in
            messageSubscription.handleEvent(eventID: eventID, headers: headers, data: data)
        },
        onError: completionHandler
    )
    
    return messageSubscription
    
}

fileprivate func subscribeToRoomCursors(
    room: PCRoom,
    cursorsInstance: Instance,
    cursorStore: PCCursorStore,
    logger: PCLogger,
    onNewReadCursorHook: @escaping (PCCursor) -> Void,
    completionHandler: @escaping PCErrorCompletionHandler
) -> PCCursorSubscription {
    let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(room.id)"

    let subscribeRequest = PPRequestOptions(
        method: HTTPMethod.SUBSCRIBE.rawValue,
        path: path
    )

    var resumableSub = PPResumableSubscription(
        instance: cursorsInstance,
        requestOptions: subscribeRequest
    )

    let cursorSubscription = PCCursorSubscription(
        resumableSubscription: resumableSub,
        cursorStore: cursorStore,
        logger: logger,
        onNewReadCursorHook: onNewReadCursorHook,
        initialStateHandler: { result in
            switch result {
            case .error(let err):
                completionHandler(err)
            case .success(let existing, let new):
                if room.subscriptionPreviouslyEstablished {
                    reconcileCursors(
                        new: new,
                        old: existing,
                        onNewReadCursorHook: onNewReadCursorHook
                    )
                }
                completionHandler(nil)
            }
        }
    )

    cursorsInstance.subscribeWithResume(
        with: &resumableSub,
        using: subscribeRequest,
        onEvent: { [unowned cursorSubscription] eventID, headers, data in
            cursorSubscription.handleEvent(eventID: eventID, headers: headers, data: data)
        },
        onError: completionHandler
    )

    return cursorSubscription
}

fileprivate func subscribeToRoomMemberships(
    room: PCRoom,
    instance: Instance,
    userStore: PCGlobalUserStore,
    roomStore: PCRoomStore,
    logger: PCLogger,
    onUserJoinedHook: @escaping (PCUser) -> Void,
    onUserLeftHook: @escaping (PCUser) -> Void,
    completionHandler: @escaping PCErrorCompletionHandler
) -> PCMembershipSubscription {
    let path = "/rooms/\(room.id)/memberships"

    let subscribeRequest = PPRequestOptions(
        method: HTTPMethod.SUBSCRIBE.rawValue,
        path: path
    )

    var resumableSub = PPResumableSubscription(
        instance: instance,
        requestOptions: subscribeRequest
    )

    let membershipSubscription = PCMembershipSubscription(
        roomID: room.id,
        resumableSubscription: resumableSub,
        userStore: userStore,
        roomStore: roomStore,
        logger: logger,
        onUserJoinedHook: onUserJoinedHook,
        onUserLeftHook: onUserLeftHook,
        initialStateHandler: { result in
            switch result {
            case .error(let err):
                completionHandler(err)
            case .success(let existing, let new):
                if room.subscriptionPreviouslyEstablished {
                    reconcileMemberships(
                        new: new,
                        old: existing,
                        onUserJoinedHook: onUserJoinedHook,
                        onUserLeftHook: onUserLeftHook
                    )
                }
                completionHandler(nil)
            }
        }
    )

    instance.subscribeWithResume(
        with: &resumableSub,
        using: subscribeRequest,
        onEvent: { [unowned membershipSubscription] eventID, headers, data in
            membershipSubscription.handleEvent(eventID: eventID, headers: headers, data: data)
        },
        onError: completionHandler
    )

    return membershipSubscription
}
