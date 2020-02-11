
protocol StoreDelegate: AnyObject {
    func store(_ store: Store, didUpdateState state: ChatState)
}

protocol HasStore {
    var store: Store { get }
}

protocol Store {
    var state: ChatState { get }
    func dispatch(action: Action)
}

class ConcreteStore: Store {
    
    typealias Dependencies =
        HasReducer_Master
        & HasReducer_Model_User_forInitialState
        & HasReducer_Model_Rooms_forInitialState
        & HasReducer_Model_Rooms_forRemovedFromRoom
        & HasReducer_UserSubscription_InitialState
        & HasReducer_UserSubscription_RemovedFromRoom
    
    private let dependencies: Dependencies
    private weak var delegate: StoreDelegate?
    
    private(set) var state: ChatState {
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
        state = self.dependencies.reducer_master(action, state, dependencies)
    }
}
