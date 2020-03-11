import Foundation

/// A repository which exposes a collection of all rooms joined by the user.
///
/// Construct an instance of this class using `Chatkit.createJoinedRoomsRepository(...)`
///
/// ## What is provided
///
/// The repository exposes a state with a set of `rooms` which presents the rooms that the current user
/// is a member of.
///
/// ## Receiving live updates
///
/// In order to be notified when the contents of the `rooms` or the `state` of the connection changes,
/// implement the `JoinedRoomsRepositoryDelegate` protocol and assign
/// the `JoinedRoomsRepository.delegate` property.
///
/// ## Understanding the `state` of the repository
///
/// The `state` property describes the state of the live update connection, either
///   - `.initializing`: awaiting the initial set of data, or
///   - `.connected`: updates are flowing live, or
///   - `.degraded`: updates may be delayed due to network problems, or
///   - `.closed`: the connection is closed, no further updates available.
public class JoinedRoomsRepository: JoinedRoomsRepositoryProtocol {
    
    // MARK: - Types
    
    typealias Dependencies = HasTransformer
    
    // MARK: - Properties
    
    private let buffer: Buffer
    private let connectivityMonitor: ConnectivityMonitor
    private let dependencies: Dependencies
    
    private var versionedState: VersionedState?
    private var connectionState: ConnectionState
    
    public private(set) var state: JoinedRoomsRepositoryState {
        didSet {
            if state != oldValue {
                if let delegate = self.delegate as? JoinedRoomsViewModel {
                    // We know that the JoinedRoomsViewModel has been coded so that it dispatches to its own
                    // delegate on the main thread.  So we do not need to dispatch to the main thread here.
                    delegate.joinedRoomsRepository(self, didUpdateState: state)
                }
                else {
                    DispatchQueue.main.async {
                        self.delegate?.joinedRoomsRepository(self, didUpdateState: self.state)
                    }
                }
            }
        }
    }
    
    /// The object that is notified when the `state` has changed.
    public weak var delegate: JoinedRoomsRepositoryDelegate?
    
    // MARK: - Initializers
    
    init(buffer: Buffer, connectivityMonitor: ConnectivityMonitor, dependencies: Dependencies) {
        self.buffer = buffer
        self.connectivityMonitor = connectivityMonitor
        self.dependencies = dependencies
        
        self.versionedState = buffer.currentState
        self.connectionState = connectivityMonitor.connectionState
        
        self.state = JoinedRoomsRepository.state(forConnectionState: connectivityMonitor.connectionState,
                                                 versionedState: buffer.currentState,
                                                 previousVersionedState: nil,
                                                 usingTransformer: dependencies.transformer)
        
        self.buffer.delegate = self
        self.connectivityMonitor.delegate = self
    }
    
    // MARK: - Private methods
    
    private static func state(forConnectionState connectionState: ConnectionState, versionedState: VersionedState?, previousVersionedState: VersionedState?, usingTransformer transformer: Transformer) -> JoinedRoomsRepositoryState {
        if let versionedState = versionedState {
            let rooms = Set(versionedState.chatState.joinedRooms.map { transformer.transform(state: $0) })
            let changeReason = transformer.transform(currentState: versionedState, previousState: previousVersionedState)
            
            if connectionState == .connected {
                return .connected(rooms: rooms, changeReason: changeReason)
            }
            else if case let .degraded(error) = connectionState {
                return .degraded(rooms: rooms, error: error, changeReason: changeReason)
            }
        }
        
        if case let .initializing(error) = connectionState {
            return .initializing(error: error)
        }
        else if case let .closed(error) = connectionState {
            return .closed(error: error)
        }
        
        return .initializing(error: nil)
    }
    
}

// MARK: - Buffer delegate

extension JoinedRoomsRepository: BufferDelegate {
    
    func buffer(_ buffer: Buffer, didUpdateState state: VersionedState) {
        self.state = JoinedRoomsRepository.state(forConnectionState: self.connectionState,
                                                 versionedState: state,
                                                 previousVersionedState: self.versionedState,
                                                 usingTransformer: self.dependencies.transformer)
        self.versionedState = state
    }
    
}

// MARK: - Connectivity monitor delegate

extension JoinedRoomsRepository: ConnectivityMonitorDelegate {
    
    func connectivityMonitor(_ connectivityMonitor: ConnectivityMonitor, didUpdateConnectionState connectionState: ConnectionState) {
        self.state = JoinedRoomsRepository.state(forConnectionState: connectionState,
                                                 versionedState: self.versionedState,
                                                 previousVersionedState: self.versionedState,
                                                 usingTransformer: self.dependencies.transformer)
        self.connectionState = connectionState
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `state` property of a `JoinedRoomsRepository`
/// has changed.
public protocol JoinedRoomsRepositoryDelegate: AnyObject {
    
    /// Notifies the receiver that the `state` of the repository has changed.
    ///
    /// - Parameters:
    ///     - joinedRoomsRepository: The `JoinedRoomsRepository` that called the method.
    ///     - state: The updated value of the `state`.
    func joinedRoomsRepository(_ joinedRoomsRepository: JoinedRoomsRepository, didUpdateState state: JoinedRoomsRepositoryState)
    
}

// MARK: - Protocol

protocol JoinedRoomsRepositoryProtocol: AnyObject {
    
    var state: JoinedRoomsRepositoryState { get }
    var delegate: JoinedRoomsRepositoryDelegate? { get set }
    
}
