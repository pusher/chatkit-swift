import Foundation

/// A provider which exposes a collection of messages for a given room.
///
/// Construct an instance of this class using `Chatkit.createMessagesProvider(...)`
///
/// ## What is provided
///
/// The provider exposes an array, `messages: [Message]` which contains a subset of the messages for a given `Room`.
///
/// Initially, the `messages` array contains the most recent messages from the room.
///
/// New messages arriving in the room are added in real time.
///
/// Older messages can be requested using `MessagesProvider.fetchOlderMessages(...)`.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `messages` changes, implement the `MessagesProviderDelegate` protocol and assign the `MessagesProvider.delegate` property.
///
/// Note that when the provider is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the Provider
///
/// The provider provides both live updates to current data, and paged access to older data.
///
/// The `MessagesProvider.state` tuple allows you to understand the current state of both:
///
/// - the `realTime` component (an instance of `RealTimeProviderState`) describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
/// - the `paged` component (an instance of `PagedProviderState`) describes whether the fill set of data has been fetched or not, either
///   - `.fullyPopulated`: all data has been retrieved,
///   - `.partiallyPopulated`: more data can be fetched from the Chatkit service, or
///   - `.fetching`: more data is currently being requested from the Chatkit service.
///
public class MessagesProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of messages.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    ///
    /// - Parameters:
    ///     - realTime: The current state of the provider related to the real time web service.
    ///     - paged: The current state of the provider related to the non-real time web service.
    public private(set) var state: (realTime: RealTimeProviderState, paged: PagedProviderState)
    
    /// The object that is notified when the list `messages` has changed.
    public weak var delegate: MessagesProviderDelegate?
    
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

/// A delegate protocol for being notified when the `messages` array of a `MessagesProvider` has changed.
public protocol MessagesProviderDelegate: class {
    
    /// Called when old messages requested with `MessagesProvider.fetchOlderMessages(...)` have been added to the collection.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - messages: The array of older messages received from the web service.
    func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveOlderMessages messages: [Message])
    
    /// Called when new messages have been added to the collection.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - messages: The new message received from the web service.
    func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveNewMessage message: Message)
    
    /// Called when a message in the collection has been updated.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - message: The updated value of the message.
    ///     - previousValue: The value of the message prior to the update.
    func messagesProvider(_ messagesProvider: MessagesProvider, didUpdateMessage message: Message, previousValue: Message)
    
    /// Called when a message in the collection has been deleted.
    ///
    /// - Parameters:
    ///     - messagesProvider: The `MessagesProvider` that called the method.
    ///     - message: The message removed from the maintened collection of messages.
    func messagesProvider(_ messagesProvider: MessagesProvider, didRemoveMessage message: Message)
    
}
