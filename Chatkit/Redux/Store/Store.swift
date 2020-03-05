import Foundation

protocol Store {
    
    var state: VersionedState { get }
    
    func dispatch(action: Action)
    func register(_ listener: StoreListener) -> VersionedState
    func unregister(_ listener: StoreListener)
    
}

// MARK: - Concrete implementation

class ConcreteStore: Store {
    
    // MARK: - Types
    
    typealias Dependencies = HasMasterReducer
        & HasUserReducer
        & HasRoomListReducer
        & HasUserSubscriptionInitialStateReducer
        & HasUserSubscriptionAddedToRoomReducer
        & HasUserSubscriptionRemovedFromRoomReducer
        & HasUserSubscriptionRoomUpdatedReducer
        & HasUserSubscriptionRoomDeletedReducer
        & HasUserSubscriptionReadStateUpdatedReducer
        & HasSubscriptionStateUpdatedReducer
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    private var listeners: NSHashTable<AnyObject>
    
    private(set) var state: VersionedState {
        didSet {
            if state != oldValue {
                self.notify(state: state)
            }
        }
    }
    
    // MARK: - Initializers
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.state = .initial
        self.listeners = NSHashTable.weakObjects()
    }
    
    // MARK: - Store
    
    func dispatch(action: Action) {
        self.state = self.dependencies.masterReducer(action, self.state, self.dependencies)
    }
    
    @discardableResult func register(_ listener: StoreListener) -> VersionedState {
        self.listeners.add(listener)
        return self.state
    }
    
    func unregister(_ listener: StoreListener) {
        self.listeners.remove(listener)
    }
    
    // MARK: - Private methods
    
    private func notify(state: VersionedState) {
        for listener in self.listeners.allObjects {
            if let listener = listener as? StoreListener {
                listener.store(self, didUpdateState: state)
            }
        }
    }
    
}

// MARK: - Listener

protocol StoreListener: AnyObject { // AnyObject is neccessary to use `===` operator
    
    func store(_ store: Store, didUpdateState state: VersionedState)
    
}

// MARK: - Dependencies

protocol HasStore {
    
    var store: Store { get }
    
}
