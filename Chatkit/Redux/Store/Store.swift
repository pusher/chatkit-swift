
protocol StoreDelegate: AnyObject {
    func store(_ store: Store, didUpdateState state: MasterState)
}

protocol HasStore {
    var store: Store { get }
}

protocol Store {
    var state: MasterState { get }
    func dispatch(action: Action)
}

class ConcreteStore: Store {
    
    typealias Dependencies =
        HasMasterReducer
        & HasUserReducer
        & HasRoomListReducer
        & HasUserSubscriptionInitialStateReducer
        & HasUserSubscriptionRemovedFromRoomReducer
        & HasUserSubscriptionRoomUpdatedReducer
        & HasUserSubscriptionRoomDeletedReducer
        & HasUserSubscriptionReadStateUpdatedReducer
    
    private let dependencies: Dependencies
    private weak var delegate: StoreDelegate?
    
    private(set) var state: MasterState {
        didSet {
            if state != oldValue {
                self.delegate?.store(self, didUpdateState: state)
            }
        }
    }
    
    init(dependencies: Dependencies, delegate: StoreDelegate?) {
        self.dependencies = dependencies
        self.delegate = delegate
        // Ensure the state is set *AFTER* the delegate so its `didSet` triggers a call to the delegate and its notified of the initial state
        self.state = .empty
    }
    
    func dispatch(action: Action) {
        state = self.dependencies.masterReducer(action, state, dependencies)
    }
}
