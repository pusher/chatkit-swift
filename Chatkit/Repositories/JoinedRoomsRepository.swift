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
public class JoinedRoomsRepository: JoinedRoomsRepositoryProtocol {
    
    // MARK: - Types
    
    typealias Dependencies = HasTransformer
    
    // MARK: - Properties
    
    private let buffer: Buffer
    private let connectivityMonitor: ConnectivityMonitor
    private let dependencies: Dependencies
    
    private var versionedState: VersionedState?
    private var connectionState: ConnectionState
    
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
        self.dependencies = dependencies
        
        self.versionedState = buffer.currentState
        self.connectionState = connectivityMonitor.connectionState
        
        self.state = JoinedRoomsRepository.state(forConnectionState: connectivityMonitor.connectionState,
                                                 currentVersionedState: buffer.currentState,
                                                 previousVersionedState: nil,
                                                 usingTransformer: dependencies.transformer)
        
        self.buffer.delegate = self
        self.connectivityMonitor.delegate = self
    }
    
    // MARK: - Private methods
    
    private static func state(forConnectionState connectionState: ConnectionState, currentVersionedState: VersionedState?, previousVersionedState: VersionedState?, usingTransformer transformer: Transformer) -> State {
        if case let .initializing(error) = connectionState {
            return .initializing(error: error)
        }
        else if case let .closed(error) = connectionState {
            return .closed(error: error)
        }
        else if let currentVersionedState = currentVersionedState {
            let rooms = Set(currentVersionedState.chatState.joinedRooms.map { transformer.transform(state: $0) })
            let changeReason = transformer.transform(currentState: currentVersionedState, previousState: previousVersionedState)
            
            if connectionState == .connected {
                return .connected(rooms: rooms, changeReason: changeReason)
            }
            else if case let .degraded(error) = connectionState {
                return .degraded(rooms: rooms, error: error, changeReason: changeReason)
            }
        }
        
        return .initializing(error: nil)
    }
    
}

// MARK: - Buffer delegate

extension JoinedRoomsRepository: BufferDelegate {
    
    func buffer(_ buffer: Buffer, didUpdateState state: VersionedState) {
        self.state = JoinedRoomsRepository.state(forConnectionState: self.connectionState,
                                                 currentVersionedState: state,
                                                 previousVersionedState: self.versionedState,
                                                 usingTransformer: self.dependencies.transformer)
        self.versionedState = state
    }
    
}

// MARK: - Connectivity monitor delegate

extension JoinedRoomsRepository: ConnectivityMonitorDelegate {
    
    func connectivityMonitor(_ connectivityMonitor: ConnectivityMonitor, didUpdateConnectionState connectionState: ConnectionState) {
        self.state = JoinedRoomsRepository.state(forConnectionState: connectionState,
                                                 currentVersionedState: self.versionedState,
                                                 previousVersionedState: self.versionedState,
                                                 usingTransformer: self.dependencies.transformer)
        self.connectionState = connectionState
    }
    
}

// MARK: - Delegate

public protocol JoinedRoomsRepositoryDelegate: AnyObject {
    
    func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateState state: JoinedRoomsRepository.State)
    
}

// MARK: - Protocol

protocol JoinedRoomsRepositoryProtocol: AnyObject {
    
    var state: JoinedRoomsRepository.State { get }
    var delegate: JoinedRoomsRepositoryDelegate? { get set }
    
}
