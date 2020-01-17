
// We may want to use a Set<StoreListener> in future but that will require type erasing
// I am using an Array at present for ease and speed.

//struct AnyStoreListener {
//    private let storeListener: StoreListener
//    init(storeListener: StoreListener) {
//        self.storeListener = storeListener
//    }
//}
//
//// Use our existing Hashable implementation
//extension AnyStoreListener: Hashable {}




protocol StoreListener: class { // class is neccessary to use `===` operator
    func store(_ store: Store, didUpdateState state: State)
}


protocol HasStoreBroadcaster {
    var storeBroadcaster: StoreBroadcaster { get }
}

protocol StoreBroadcaster: StoreDelegate {
    func register(_ listener: StoreListener)
    // TODO unregister
}

class ConcreteStoreBroadcaster: StoreBroadcaster {
    
    typealias Dependencies = Any // No dependencies for now
    
    let dependencies: Dependencies
    
    var listeners = Array<StoreListener>()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: StoreBroadcaster
    
    func register(_ listener: StoreListener) {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
    }

    // MARK: StoreDelegate
    
    func store(_ store: Store, didUpdateState state: State) {
        for listener in listeners {
            listener.store(store, didUpdateState: state)
        }
    }
    
}
