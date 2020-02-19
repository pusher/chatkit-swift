import Foundation

/// A provider which exposes the set of `User`s which are members of a given `Room`.
///
/// This class provides a real time collection, if you just want a snapshot of the members of a room *now*, see `Chatkit.members(...)`.
///
/// Construct an instance of this class using `Chatkit.createRoomMembersProvider(...)`
///
/// ## What is provided
///
/// The provider exposes a set, `members: Set<User>` which represents the members of a room.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `members` changes, implement the `RoomMembersProviderDelegate` protocol and assign the `RoomMembersProvider.delegate` property.
///
/// Note that when the provider is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the provider
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class RoomMembersProvider {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the provider manages a collection of members.
    public let roomIdentifier: String
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the content of the maintained collection of room members changed.
    public weak var delegate: RoomMembersProviderDelegate?
    
    /// The set of all room members for the given room.
    public var members: Set<User> {
        return []
    }
    
    // MARK: - Initializers
    
    init(room: Room) {
        self.roomIdentifier = room.identifier
        self.state = .connected
    }
    
}

// MARK: - Delegate

/// A delegate protocol that describes methods that will be called by the associated
/// `RoomMembersProvider` when the maintainted collection of room members have changed.
public protocol RoomMembersProviderDelegate: class {
    
    /// Notifies the receiver that a new member have joined the room.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - user: The user who joined the room.
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, userDidJoin user: User)
    
    /// Notifies the receiver that a user from the maintened collection of room members have
    /// left the room.
    ///
    /// - Parameters:
    ///     - roomMembersProvider: The `RoomMembersProvider` that called the method.
    ///     - user: The user who left the room.
    func roomMembersProvider(_ roomMembersProvider: RoomMembersProvider, userDidLeave user: User)
    
}
