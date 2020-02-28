
protocol ConnectivityMonitor: StoreListener {
    
    var subscriptionType: String { get }    // TODO: Replace with SubscriptionType when available.
    var connectionState: ConnectionState { get }
    var delegate: ConnectivityMonitorDelegate? { get set }
    
}

// MARK: - Concrete implementation

class ConcreteConnectivityMonitor: ConnectivityMonitor {
    
    // MARK: - Types
    
    typealias Dependencies = HasStore
    
    // MARK: - Properties
    
    let subscriptionType: String
    private(set) var connectionState: ConnectionState
    
    private let dependencies: Dependencies
    
    weak var delegate: ConnectivityMonitorDelegate?
    
    // MARK: - Initializers
    
    init(subscriptionType: String, dependencies: Dependencies) {
        self.subscriptionType = subscriptionType
        self.connectionState = .closed(error: nil)
        self.dependencies = dependencies
        
        self.registerListener()
    }
    
    // MARK: - Store listener
    
    func store(_ store: Store, didUpdateState state: VersionedState) {
        self.updateStateIfNeeded(fromVersionedState: state)
    }
    
    // MARK: - Private methods
    
    private func registerListener() {
        // It really feels like this should be done by a different object, but such approach is forced on this class by the DI mechanism.
        let versionedState = self.dependencies.store.register(self)
        self.connectionState = self.connectionState(fromVersionedState: versionedState)
    }
    
    private func updateStateIfNeeded(fromVersionedState versionedState: VersionedState) {
        let newConnectionState = self.connectionState(fromVersionedState: versionedState)
        
        guard newConnectionState != self.connectionState else {
            return
        }
        
        self.connectionState = newConnectionState
        
        self.delegate?.connectivityMonitor(self, didUpdateConnectionState: newConnectionState)
    }
    
    private func connectionState(fromVersionedState versionedState: VersionedState) -> ConnectionState {
        let connectionState = versionedState.auxiliaryState.subscriptions[self.subscriptionType]
        return connectionState ?? .closed(error: nil)
    }
    
    // MARK: - Memory management
    
    deinit {
        self.dependencies.store.unregister(self)
    }
    
}

// MARK: - Delegate

protocol ConnectivityMonitorDelegate: AnyObject {
    
    func connectivityMonitor(_ connectivityMonitor: ConnectivityMonitor, didUpdateConnectionState connectionState: ConnectionState)
    
}