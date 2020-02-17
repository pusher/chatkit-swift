import Foundation

/// A provider which exposes a collection of all rooms joined by the user.
///
/// Construct an instance of this class using `Chatkit.createJoinedRoomsProvider(...)`
///
/// ## What is provided
///
/// The provider exposes a set, `rooms: Set<Room>` which presents the rooms that the current user is a member of.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `rooms` changes, implement the `JoinedRoomsProviderDelegate` protocol and assign the `JoinedRoomsProvider.delegate` property.
///
/// Note that when the provider is first returned to you, it will already be populated, and the delegate will only be invoked when the contents change.
///
/// ## Understanding the `state` of the provider
///
/// The `state` property describes the state of the live update connection, either
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems.
///
public class JoinedRoomsProvider {
    
    typealias Dependencies = HasStoreBroadcaster
    
    private let dependencies: Dependencies
    
    // MARK: - Properties
    
    /// The current state of the provider.
    public private(set) var state: RealTimeProviderState
    
    /// The object that is notified when the set `rooms` has changed.
    public weak var delegate: JoinedRoomsProviderDelegate?
    
    /// The set of all rooms joined by the user.
    public var rooms: Set<Room>
    
    // MARK: - Initializers
    
    init(currentUser: User, dependencies: Dependencies) {
        self.state = .connected
        self.dependencies = dependencies
        self.rooms = []
        
        // TODO needs to move elsewhere once we have a transformer
        let state = dependencies.storeBroadcaster.register(self)
        
        var rooms: Set<Room> = []
        for roomState in state.joinedRooms.rooms.values {
            let room = EntityParser.room(fromRoomState: roomState)
            rooms.insert(room)
        }
        self.rooms = rooms
    }
    
    deinit {
        self.dependencies.storeBroadcaster.unregister(self)
    }
    
}


// MARK: - Delegate

/// A delegate protocol for being notified when the `rooms` property of a `JoinedRoomsProvider` has changed.
public protocol JoinedRoomsProviderDelegate: class {
    
    /// Notifies the receiver that the current user has joined a room, and that it has been added to the set.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room joined by the user.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didJoinRoom room: Room)
    
    /// Notifies the receiver that a room the current user is a member of has been updated.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The new value of the room.
    ///     - previousValue: The value of the room befrore it was updated.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didUpdateRoom room: Room, previousValue: Room)
    
    /// Notifies the receiver that the current user has left, or been removed from a room.
    ///
    /// - Parameters:
    ///     - joinedRoomsProvider: The `JoinedRoomsProvider` that called the method.
    ///     - room: The room which the user is no longer a member of.
    func joinedRoomsProvider(_ joinedRoomsProvider: JoinedRoomsProvider, didLeaveRoom room: Room)
}
