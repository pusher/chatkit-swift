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
    
    // MARK: - Types
    
    typealias Dependencies = HasTransformer
    
    // MARK: - Properties
    
    private let buffer: Buffer
    private let connectivityMonitor: ConnectivityMonitor
    private let dependencies: Dependencies
    
    private var versionedState: VersionedState?
    
    /// The current state of the repository.
    public private(set) var state: State {
        didSet {
            if state != oldValue {
                self.delegate?.joinedRoomsRepository(self, didUpdateState: state)
            }
        }
    }
    
    /// The object that is notified when the set `rooms` has changed.
    public weak var delegate: JoinedRoomsRepositoryDelegate?
    
    // MARK: - Initializers
    
    init(buffer: Buffer, connectivityMonitor: ConnectivityMonitor, dependencies: Dependencies) {
        self.buffer = buffer
        self.connectivityMonitor = connectivityMonitor
        self.versionedState = buffer.currentState
        self.state = .initializing(error: nil) // TODO: Determine what kind of error we might receive here from our auxiliary state.
        self.dependencies = dependencies
        
        self.buffer.delegate = self
        self.connectivityMonitor.delegate = self
    }
    
    // MARK: - Private methods
    
    private func update(versionedState: VersionedState, rooms: Set<Room>, changeReason: ChangeReason?) {
        switch self.state {
        case .connected(_, _):
            self.state = .connected(rooms: rooms, changeReason: changeReason)
            
        case let .degraded(_, error, _):
            self.state = .degraded(rooms: rooms, error: error, changeReason: changeReason)
            
        case .initializing(_),
             .closed(_):
            break
        }
        
        self.versionedState = versionedState
    }
    
}

// MARK: - Buffer delegate

extension JoinedRoomsRepository: BufferDelegate {
    
    func buffer(_ buffer: Buffer, didUpdateState state: VersionedState) {
        let rooms = state.chatState.joinedRooms.map { self.dependencies.transformer.transform(state: $0) }
        let changeReason: ChangeReason? = self.dependencies.transformer.transform(currentState: state, previousState: self.versionedState)
        
        self.update(versionedState: state, rooms: Set(rooms), changeReason: changeReason)
    }
    
}

// MARK: - Connectivity monitor delegate

extension JoinedRoomsRepository: ConnectivityMonitorDelegate {
    
    func connectivityMonitor(_ connectivityMonitor: ConnectivityMonitor, didUpdateConnectionState connectionState: ConnectionState) {
    }
}

// MARK: - Delegate

public protocol JoinedRoomsRepositoryDelegate: AnyObject {
    
    func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateState state: JoinedRoomsRepository.State)
    
}
