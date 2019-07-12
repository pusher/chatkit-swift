import Foundation

class PCConnectionCoordinator {
    private var queue = DispatchQueue(label: "com.pusher.chatkit.connection-coordinator-\(UUID().uuidString)")
    var completedConnectionEvents: Set<PCConnectionEvent> = []
    var connectionEventHandlers: [PCConnectionEventHandler] = []
    var logger: PCLogger

    init(logger: PCLogger) {
        self.logger = logger
    }

    func connectionEventCompleted(_ event: PCConnectionEvent) {
        queue.sync {
            self.logger.log("\(event.debugDescription) completed", logLevel: .verbose)

            let insertResult = self.completedConnectionEvents.insert(event)
            guard insertResult.inserted else {
                self.logger.log(
                    "\(event.debugDescription) completion communicated to connection coordinator, but event of same type already stored",
                    logLevel: .debug
                )
                return
            }

            var completionHandlersToCall: [PCConnectionEventHandler] = []
            var completionHandlersToKeep: [PCConnectionEventHandler] = []

            for connectionEventHanlder in self.connectionEventHandlers {
                if connectionEventHanlder.dependencies.isSubset(of: self.completedConnectionEvents) {
                    completionHandlersToCall.append(connectionEventHanlder)
                } else {
                    completionHandlersToKeep.append(connectionEventHanlder)
                }
            }

            self.connectionEventHandlers = completionHandlersToKeep

            completionHandlersToCall.forEach { completionHandler in
                let eventsToCallHandlerWith = Array(self.completedConnectionEvents.intersection(completionHandler.dependencies))
                completionHandler.handler(eventsToCallHandlerWith)
            }

            if self.completedConnectionEvents == allConnectionEvents {
                self.reset(alreadyInCoordinatorQueue: true)
            }
        }
    }

    func addConnectionCompletionHandler(_ handler: @escaping (PCCurrentUser?, Error?) -> Void) {
        queue.sync {
            self.connectionEventHandlers.append(
                PCConnectionEventHandler(
                    handler: { events in
                        for event in events {
                            switch event.result {
                            case .userSubscriptionInit(let currentUser, let error):
                                handler(currentUser, error)
                            default:
                                break
                            }
                        }
                    },
                    dependencies: allConnectionEvents
                )
            )
        }
    }

    func reset(alreadyInCoordinatorQueue: Bool = false) {
        if alreadyInCoordinatorQueue {
            completedConnectionEvents = []
            connectionEventHandlers = []
        } else {
            queue.sync {
                self.completedConnectionEvents = []
                self.connectionEventHandlers = []
            }
        }
    }
}

class PCConnectionEventHandler {
    let handler: ([PCConnectionEvent]) -> Void
    let dependencies: Set<PCConnectionEvent>

    init(
        handler: @escaping ([PCConnectionEvent]) -> Void,
        dependencies: Set<PCConnectionEvent>
    ) {
        self.handler = handler
        self.dependencies = dependencies
    }
}

// TODO: Sourcery should be used for all of this generation stuff
class PCConnectionEvent {
    let type: PCConnectionEventType
    let result: PCConnectionEventResult

    fileprivate init(type: PCConnectionEventType, result: PCConnectionEventResult) {
        self.type = type
        self.result = result
    }

    convenience init(currentUser: PCCurrentUser?, error: Error?) {
        self.init(type: .userSubscriptionInit, result: .userSubscriptionInit(currentUser: currentUser, error: error))
    }

    convenience init(presenceSubscription: PCPresenceSubscription?, error: Error?) {
        self.init(type: .presenceSubscriptionInit, result: .presenceSubscriptionInit(presenceSubscription: presenceSubscription, error: error))
    }

    fileprivate static func userSubscriptionInit() -> PCConnectionEvent {
        return PCConnectionEvent(type: .userSubscriptionInit, result: .userSubscriptionInit(currentUser: nil, error: nil))
    }

    fileprivate static func presenceSubscriptionInit() -> PCConnectionEvent {
        return PCConnectionEvent(type: .presenceSubscriptionInit, result: .presenceSubscriptionInit(presenceSubscription: nil, error: nil))
    }
}

extension PCConnectionEvent: CustomDebugStringConvertible {
    var debugDescription: String {
        return "Connection event type: \(self.type.rawValue), with result: \(self.result.debugDescription)"
    }
}

let PCUserSubscriptionInitEvent = PCConnectionEvent.userSubscriptionInit()
let PCPresenceSubscriptionInitEvent = PCConnectionEvent.presenceSubscriptionInit()

fileprivate let allConnectionEvents: Set<PCConnectionEvent> = [
    PCUserSubscriptionInitEvent,
    PCPresenceSubscriptionInitEvent,
]

extension PCConnectionEvent: Hashable {
    var hashValue: Int {
        return self.type.hashValue
    }

    static func ==(lhs: PCConnectionEvent, rhs: PCConnectionEvent) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

enum PCConnectionEventResult {
    case userSubscriptionInit(currentUser: PCCurrentUser?, error: Error?)
    case presenceSubscriptionInit(presenceSubscription: PCPresenceSubscription?, error: Error?)
}

extension PCConnectionEventResult: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .userSubscriptionInit(_, let error), .presenceSubscriptionInit(_, let error):
            return error == nil ? "success" : "\(error!.localizedDescription)"
        }
    }
}

enum PCConnectionEventType: String {
    case userSubscriptionInit
    case presenceSubscriptionInit
}

extension PCConnectionEventResult: Hashable {
    var hashValue: Int {
        switch self {
        case .userSubscriptionInit(_, _):
            return 0
        case .presenceSubscriptionInit(_, _):
            return 1
        }
    }

    static func ==(lhs: PCConnectionEventResult, rhs: PCConnectionEventResult) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
