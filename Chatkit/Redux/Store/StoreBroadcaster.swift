
// We may want to use a Set<StoreListener> in future but that will require type erasing
// I am using an Array at present for ease and speed.

// struct AnyStoreListener {
//    private let storeListener: StoreListener
//    init(storeListener: StoreListener) {
//        self.storeListener = storeListener
//    }
// }
//
/// / Use our existing Hashable implementation
// extension AnyStoreListener: Hashable {}


protocol StoreListener: AnyObject { // AnyObject is neccessary to use `===` operator
    func store(_ store: Store, didUpdateState state: State)
}

protocol HasStoreBroadcaster {
    var storeBroadcaster: StoreBroadcaster { get }
}

protocol StoreBroadcaster: StoreDelegate {
    func register(_ listener: StoreListener) -> State
    func unregister(_ listener: StoreListener)
}

class ConcreteStoreBroadcaster: StoreBroadcaster {
    
    typealias Dependencies = Any // No dependencies for now
    
    private let dependencies: Dependencies
    
    private var listeners = [StoreListener]()
    
    // TODO: is this cool or would it be better if the store itself exposed its current state?
    private var state: State?
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: StoreBroadcaster
    
    func register(_ listener: StoreListener) -> State {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
        // TODO: can this be made better?
        return self.state ?? State.emptyState
    }
    
    func unregister(_ listener: StoreListener) {
        listeners.removeAll(where: { $0 === listener })
    }

    // MARK: StoreDelegate
    
    func store(_ store: Store, didUpdateState state: State) {
        self.state = state
        for listener in listeners {
            listener.store(store, didUpdateState: state)
        }
    }
    
}
