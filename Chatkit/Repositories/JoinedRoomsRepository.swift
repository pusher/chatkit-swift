import Foundation

/// A repository which exposes a collection of all rooms joined by the user.
///
/// Construct an instance of this class using `Chatkit.createJoinedRoomsRepository(...)`
///
/// ## What is provided
///
/// The repository exposes a set, `rooms: Set<Room>` which presents the rooms that the current user is a member of.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `rooms` changes, implement the `JoinedRoomsRepositoryDelegate` protocol and assign the `JoinedRoomsRepository.delegate` property.
///
/// Note that when the repository is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the repository
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class JoinedRoomsRepository {
    
    // MARK: - Properties
    
    /// The current state of the repository.
    public private(set) var state: RealTimeRepositoryState
    
    /// The object that is notified when the set `rooms` has changed.
    public weak var delegate: JoinedRoomsRepositoryDelegate?
    
    /// The set of all rooms joined by the user.
    public var rooms: Set<Room> {
        return []
    }
    
    // MARK: - Initializers
    
    init(currentUser: User) {
        self.state = .connected
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `rooms` property of a `JoinedRoomsRepository` has changed.
public protocol JoinedRoomsRepositoryDelegate: class {
    
    /// Notifies the receiver that the current user has joined a room, and that it has been added to the set.
    ///
    /// - Parameters:
    ///     - joinedRoomsRepository: The `JoinedRoomsRepository` that called the method.
    ///     - room: The room joined by the user.
    func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didJoinRoom room: Room)
    
    /// Notifies the receiver that a room the current user is a member of has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsRepository: The `JoinedRoomsRepository` that called the method.
    ///     - room: The new value of the room.
    ///     - previousValue: The value of the room befrore it was updated.
    func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateRoom room: Room, previousValue: Room)
    
    /// Notifies the receiver that the current user has left, or been removed from a room.
    ///
    /// - Parameters:
    ///     - joinedRoomsRepository: The `JoinedRoomsRepository` that called the method.
    ///     - room: The room which the user is no longer a member of.
    func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didLeaveRoom room: Room)
}
