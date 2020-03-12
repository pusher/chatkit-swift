import Foundation

/// A repository which exposes the set of `User`s which are members of a given `Room`.
///
/// This class provides a real time collection, if you just want a snapshot of the members of a room *now*, see `Chatkit.members(...)`.
///
/// Construct an instance of this class using `Chatkit.makeRoomMembersRepository(...)`
///
/// ## What is provided
///
/// The repository exposes a set, `members: Set<User>` which represents the members of a room.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `members` changes, implement the `RoomMembersRepositoryDelegate` protocol and assign the `RoomMembersRepository.delegate` property.
///
/// Note that when the repository is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the repository
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class RoomMembersRepository {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the repository manages a collection of members.
    public let roomIdentifier: String
    
    /// The current state of the repository.
    public private(set) var state: RealTimeRepositoryState
    
    /// The object that is notified when the content of the maintained collection of room members changed.
    public weak var delegate: RoomMembersRepositoryDelegate?
    
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
/// `RoomMembersRepository` when the maintainted collection of room members have changed.
public protocol RoomMembersRepositoryDelegate: class {
    
    /// Notifies the receiver that a new member have joined the room.
    ///
    /// - Parameters:
    ///     - roomMembersRepository: The `RoomMembersRepository` that called the method.
    ///     - user: The user who joined the room.
    func roomMembersRepository(_ roomMembersRepository: RoomMembersRepository, userDidJoin user: User)
    
    /// Notifies the receiver that a user from the maintened collection of room members have
    /// left the room.
    ///
    /// - Parameters:
    ///     - roomMembersRepository: The `RoomMembersRepository` that called the method.
    ///     - user: The user who left the room.
    func roomMembersRepository(_ roomMembersRepository: RoomMembersRepository, userDidLeave user: User)
    
}
