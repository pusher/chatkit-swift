
protocol StoreListener: AnyObject { // AnyObject is neccessary to use `===` operator
    func store(_ store: Store, didUpdateState state: VersionedState)
}

protocol HasStoreBroadcaster {
    var storeBroadcaster: StoreBroadcaster { get }
}

protocol StoreBroadcaster: StoreDelegate {
    func register(_ listener: StoreListener) -> VersionedState
    func unregister(_ listener: StoreListener)
}

class ConcreteStoreBroadcaster: StoreBroadcaster {
    
    typealias Dependencies = HasStore
    
    private let dependencies: Dependencies
    
    private var listeners = [StoreListener]()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: StoreBroadcaster
    
    func register(_ listener: StoreListener) -> VersionedState {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
        return self.dependencies.store.state
    }
    
    func unregister(_ listener: StoreListener) {
        listeners.removeAll(where: { $0 === listener })
    }

    // MARK: StoreDelegate
    
    func store(_ store: Store, didUpdateState state: VersionedState) {
        for listener in listeners {
            listener.store(store, didUpdateState: state)
        }
    }
    
}
