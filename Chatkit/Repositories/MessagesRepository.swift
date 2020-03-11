import Foundation

/// A repository which exposes a collection of messages for a given room.
///
/// Construct an instance of this class using `Chatkit.createMessagesRepository(...)`
///
/// ## What is provided
///
/// The repository exposes an array, `messages: [Message]` which contains a subset of the messages for a given `Room`.
///
/// Initially, the `messages` array contains the most recent messages from the room.
///
/// New messages arriving in the room are added in real time.
///
/// Older messages can be requested using `MessagesRepository.fetchOlderMessages(...)`.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `messages` changes, implement the `MessagesRepositoryDelegate` protocol and assign the `MessagesRepository.delegate` property.
///
/// Note that when the repository is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the repository
///
/// The repository provides both live updates to current data, and paged access to older data.
///
/// The `MessagesRepository.state` tuple allows you to understand the current state of both:
///
/// - the `realTime` component (an instance of `RealTimeRepositoryState`) describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
/// - the `paged` component (an instance of `PagedRepositoryState`) describes whether the fill set of data has been fetched or not, either
///   - `.fullyPopulated`: all data has been retrieved,
///   - `.partiallyPopulated`: more data can be fetched from the Chatkit service, or
///   - `.fetching`: more data is currently being requested from the Chatkit service.
///
public class MessagesRepository {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the repository manages a collection of messages.
    public let roomIdentifier: String
    
    /// The current state of the repository.
    ///
    /// - Parameters:
    ///     - realTime: The current state of the repository related to the real time web service.
    ///     - paged: The current state of the repository related to the non-real time web service.
    public private(set) var state: (realTime: RealTimeRepositoryState, paged: PagedRepositoryState)
    
    /// The object that is notified when the list `messages` has changed.
    public weak var delegate: MessagesRepositoryDelegate?
    
    /// The array of available messages for the given room.
    ///
    /// The array contains all messages for the room which have been received by the client device.
    ///
    /// Initially this will be some of the most recent messages.
    ///
    /// New messages are always added to this array.
    ///
    /// If more older messages are required, call `fetchOlderMessages(...)` to have them added to this array.
    public var messages: [Message] {
        return []
    }
    
    // MARK: - Initializers
    
    init(room: Room) {
        self.roomIdentifier = room.identifier
        
        self.state.realTime = .connected
        self.state.paged = .fullyPopulated
    }
    
    // MARK: - Methods
    
    /// Fetch more old messages from the Chatkit service and add them to the `messages` array.
    ///
    /// This call is asynchronous because messages may need to be retrieved from the network.
    ///
    /// On success, the completion handler receives `nil`, and the messages are added to the `messages` array.
    ///
    /// The `delegate` will be informed of the change to the `messages` array.
    ///
    /// - Parameters:
    ///     - numberOfMessages: The maximum number of messages that should be retrieved from
    ///     the web service.
    ///     - completionHandler: An optional completion handler invoked when the operation is complete.
    ///     The completion handler receives an Error, or nil on success.
    public func fetchOlderMessages(numberOfMessages: UInt = 10, completionHandler: CompletionHandler? = nil) {
        guard self.state.paged == .partiallyPopulated else {
            if let completionHandler = completionHandler {
                // TODO: Return error
                completionHandler(nil)
            }
            
            return
        }
        
        // TODO: Implement
        if let completionHandler = completionHandler {
            completionHandler(nil)
        }
    }
    
    /// Marks the `lastReadMessage` and all preceding messages as read.
    ///
    /// This will propagate to the currrent user's unread counts and other users which are watching the read state of the message via the Chatkit service.
    ///
    /// - Parameters:
    ///     - lastReadMessage: The last message read by the user.
    public func markMessagesAsRead(lastReadMessage: Message) {
        // TODO: Implement
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `messages` array of a `MessagesRepository` has changed.
public protocol MessagesRepositoryDelegate: class {
    
    /// Called when old messages requested with `MessagesRepository.fetchOlderMessages(...)` have been added to the collection.
    ///
    /// - Parameters:
    ///     - messagesRepository: The `MessagesRepository` that called the method.
    ///     - messages: The array of older messages received from the web service.
    func messagesRepository(_ messagesRepository: MessagesRepository, didReceiveOlderMessages messages: [Message])
    
    /// Called when new messages have been added to the collection.
    ///
    /// - Parameters:
    ///     - messagesRepository: The `MessagesRepository` that called the method.
    ///     - messages: The new message received from the web service.
    func messagesRepository(_ messagesRepository: MessagesRepository, didReceiveNewMessage message: Message)
    
    /// Called when a message in the collection has been updated.
    ///
    /// - Parameters:
    ///     - messagesRepository: The `MessagesRepository` that called the method.
    ///     - message: The updated value of the message.
    ///     - previousValue: The value of the message prior to the update.
    func messagesRepository(_ messagesRepository: MessagesRepository, didUpdateMessage message: Message, previousValue: Message)
    
    /// Called when a message in the collection has been deleted.
    ///
    /// - Parameters:
    ///     - messagesRepository: The `MessagesRepository` that called the method.
    ///     - message: The message removed from the maintened collection of messages.
    func messagesRepository(_ messagesRepository: MessagesRepository, didRemoveMessage message: Message)
    
}
