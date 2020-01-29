
enum Action {
    case subscriptionEvent(Wire.Event.EventType)
    case received(user: Wire.User)
    case fetching(userWithIdentifier: String)
}

extension Action: Equatable {}

protocol StoreDelegate: AnyObject {
    func store(_ store: Store, didUpdateState state: State)
}

protocol HasStore {
    var store: Store { get }
}

protocol Store {
    var state: State { get }
    func action(_ action: Action)
}

class ConcreteStore: Store {
    
    typealias Dependencies = Any // No dependencies for now
    
    private let dependencies: Dependencies
    private weak var delegate: StoreDelegate?
    
    private(set) var state: State {
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
        self.state = State.emptyState
    }
    
    func action(_ action: Action) {
        
        let existingState = self.state
        
        let newState: State
        
        // TODO: this whole block needs to move into a `Reducer` or `ReductionManager`
        // (and therefore this does not have full test coverage at present)
        switch action {
            
        case let .subscriptionEvent(eventType):
            
            switch eventType {
                
            case let .initialState(initialState):
                // TODO:
                let currentUser = Internal.User(
                    identifier: initialState.currentUser.identifier,
                    name: initialState.currentUser.name
                )
                
                var joinedRooms = [Internal.Room]()
                for wireRoom in initialState.rooms {
                    let joinedRoom = Internal.Room(identifier: wireRoom.identifier, name: wireRoom.name)
                    joinedRooms.append(joinedRoom)
                }
                
                newState = State(
                    currentUser: currentUser,
                    joinedRooms: joinedRooms
                )

            case let .removedFromRoom(removedFromRoom):
                // TODO:
                newState = State(
                    currentUser: existingState.currentUser,
                    joinedRooms: existingState.joinedRooms.filter { $0.identifier != removedFromRoom.roomIdentifier }
                )
                
            default:
                fatalError()
            }
            
        case let .received(user: wireUser):
            // TODO:
            let internalUser = Internal.User(
                identifier: wireUser.identifier,
                name: wireUser.name
            )
            
            newState = existingState
            
            print("unimplemented, received user \(internalUser)")
            fatalError()
            
        case let .fetching(userWithIdentifier):
            // TODO:
            newState = existingState
            
            print("unimplemented, fetching user \(userWithIdentifier)")
            fatalError()
        }
        
        self.state = newState
    }
}
