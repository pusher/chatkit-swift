
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
    
    typealias Dependencies = HasReductionManager
    
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
        self.state = self.dependencies.reductionManager.reduce(action: action, state: self.state)
    }
}
