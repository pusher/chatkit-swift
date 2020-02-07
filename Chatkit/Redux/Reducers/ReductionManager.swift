
protocol ReductionManager {
    
    func reduce(action: Action, state: ChatState) -> ChatState
    
}

// MARK: - Dependencies

protocol HasReductionManager  {
    
    var reductionManager: ReductionManager { get }
    
}

// MARK: - Concrete implementation

struct ConcreteReductionManager: ReductionManager {
    
    // MARK: - Properties
    
    private let userSubscriptionInitialStateReducer: Reducer.ReducerType<ChatState>
    private let userSubscriptionRemovedFromRoomReducer: Reducer.ReducerType<ChatState>
    
    // MARK: - Initializers
    
    init(userSubscriptionInitialStateReducer: @escaping Reducer.ReducerType<ChatState>,
         userSubscriptionRemovedFromRoomReducer: @escaping Reducer.ReducerType<ChatState>) {
        self.userSubscriptionInitialStateReducer = userSubscriptionInitialStateReducer
        self.userSubscriptionRemovedFromRoomReducer = userSubscriptionRemovedFromRoomReducer
    }
    
    // MARK: - Internal methods
    
    func reduce(action: Action, state: ChatState) -> ChatState {
        switch action {
        case .receivedInitialState(_):
            return self.userSubscriptionInitialStateReducer(action, state)
            
        case .receivedRemovedFromRoom(_):
            return self.userSubscriptionRemovedFromRoomReducer(action, state)
            
        // TODO: Test all cases listed below.
        case .received(_):
            // TODO: To be implemented
            return .empty
            
        case .fetching(_):
            // TODO: To be implemented
            return .empty
        }
    }
    
}
