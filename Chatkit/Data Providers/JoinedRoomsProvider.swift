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
        for joinedRoom in state.joinedRooms {
            let room = Self.room(fromJoinedRoom: joinedRoom)
            rooms.insert(room)
        }
        self.rooms = rooms
    }
    
    deinit {
        self.dependencies.storeBroadcaster.unregister(self)
    }
    
}

// TODO this is temporary, until the transformer is implemented
extension JoinedRoomsProvider: StoreListener {
    
    func store(_ store: Store, didUpdateState state: State) {
        
        for joinedRoom in state.joinedRooms {
            if rooms.contains(where: { $0.identifier != joinedRoom.identifier} ) {
                let room = Self.room(fromJoinedRoom: joinedRoom)
                self.rooms.insert(room)
                self.delegate?.joinedRoomsProvider(self, didJoinRoom: room)
            }
        }
        
        for currentRoom in rooms {
            if !state.joinedRooms.contains(where: { $0.identifier == currentRoom.identifier }) {
                self.rooms.remove(currentRoom)
                self.delegate?.joinedRoomsProvider(self, didLeaveRoom: currentRoom)
            }
        }
        
    }

    // TODO needs to move elsewhere
    static private func room(fromJoinedRoom joinedRoom: Internal.Room) -> Room {
        // TODO fill in the blanks
        return Room(identifier: joinedRoom.identifier,
                    name: joinedRoom.name,
                    isPrivate: false,
                    unreadCount: 0,
                    lastMessage: nil,
                    customData: nil,
                    createdAt: Date(),
                    updatedAt: Date(),
                    deletedAt: nil)
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
