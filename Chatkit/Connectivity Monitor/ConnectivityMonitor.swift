
protocol ConnectivityMonitor: AnyObject { // AnyObject is required so we can mutate the delegate value
    
    var subscriptionType: SubscriptionType { get }
    var delegate: ConnectivityMonitorDelegate? { get set }
    
}

// MARK: - Concrete implementation

class ConcreteConnectivityMonitor: ConnectivityMonitor, StoreListener {
    
    // MARK: - Types
    
    typealias Dependencies = HasStore
    
    // MARK: - Properties
    
    let subscriptionType: SubscriptionType
    
    private var connectionState: ConnectionState!
    
    private let dependencies: Dependencies
    
    weak var delegate: ConnectivityMonitorDelegate?
    
    // MARK: - Initializers
    static func makeWithInitialValue(subscriptionType: SubscriptionType, dependencies: Dependencies) -> (ConcreteConnectivityMonitor, ConnectionState) {
        let connectivityMonitor = ConcreteConnectivityMonitor(subscriptionType: subscriptionType, dependencies: dependencies)
        connectivityMonitor.connectionState = connectivityMonitor.register()
        return (connectivityMonitor, connectivityMonitor.connectionState)
    }
    
    private init(subscriptionType: SubscriptionType, dependencies: Dependencies) {
        self.subscriptionType = subscriptionType
        self.dependencies = dependencies
    }
    
    // MARK: - Store listener
    
    func store(_ store: Store, didUpdateState state: VersionedState) {
        self.updateStateIfNeeded(fromVersionedState: state)
    }
    
    // MARK: - Private methods
    
    private func register() -> ConnectionState {
        let versionedState = self.dependencies.store.register(self)
        let connectionState = self.connectionState(fromVersionedState: versionedState)
        return connectionState
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
