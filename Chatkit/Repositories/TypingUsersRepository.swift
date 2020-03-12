import Foundation

/// A repository which exposes the set of `User`s currently typing on a given `Room`.
///
/// Construct an instance of this class using `Chatkit.makeTypingUsersRepository(...)`
///
/// ## What is provided
///
/// The repository exposes a set, `typingUsers: Set<User>` which represents the members of a room.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `typingUsers` changes, implement the `TypingUsersRepositoryDelegate` protocol and assign the `TypingUsersRepository.delegate` property.
///
/// Note that when the repository is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the repository
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class TypingUsersRepository {
    
    // MARK: - Properties
    
    /// The identifier of the room for which the repository manages a collection of typing users.
    public let roomIdentifier: String
    
    /// The current state of the repository.
    public private(set) var state: RealTimeRepositoryState
    
    /// The object that is notified when the content of the maintained collection of typing users changed.
    public weak var delegate: TypingUsersRepositoryDelegate?
    
    /// The set of all users currently typing on a given room.
    public var typingUsers: Set<User> {
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
/// `TypingUsersRepository` when the maintainted collection of typing users have changed.
public protocol TypingUsersRepositoryDelegate: class {
    
    /// Notifies the receiver that a user started typing in the room.
    ///
    /// - Parameters:
    ///     - roomMembersRepository: The `RoomMembersRepository` that called the method.
    ///     - user: The user who started typing in the room.
    func typingUsersRepository(_ typingUsersRepository: TypingUsersRepository, userDidStartTyping user: User)
    
    /// Notifies the receiver that a user stopped typing in the room.
    ///
    /// - Parameters:
    ///     - typingUsersRepository: The `TypingUsersRepository` that called the method.
    ///     - user: The user who stopped typing in the room.
    func typingUsersRepository(_ typingUsersRepository: TypingUsersRepository, userDidStopTyping user: User)
    
}
