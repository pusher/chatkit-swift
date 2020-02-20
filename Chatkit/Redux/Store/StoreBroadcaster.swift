
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
    
    private var listeners: NSHashTable<AnyObject>
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.listeners = NSHashTable.weakObjects()
    }
    
    // MARK: StoreBroadcaster
    
    func register(_ listener: StoreListener) -> VersionedState {
        self.listeners.add(listener)
        return self.dependencies.store.state
    }
    
    func unregister(_ listener: StoreListener) {
        self.listeners.remove(listener)
    }

    // MARK: StoreDelegate
    
    func store(_ store: Store, didUpdateState state: VersionedState) {
        for listener in self.listeners.allObjects {
            if let listener = listener as? StoreListener {
                listener.store(store, didUpdateState: state)
            }
        }
    }
    
}
