
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
    
    private let userSubscriptionInitialStateReducer: Reducer.ReducerType<ReceivedInitialStateAction, ChatState>
    private let userSubscriptionRemovedFromRoomReducer: Reducer.ReducerType<ReceivedRemovedFromRoomAction, ChatState>
    
    // MARK: - Initializers
    
    init(userSubscriptionInitialStateReducer: @escaping Reducer.ReducerType<ReceivedInitialStateAction, ChatState>,
         userSubscriptionRemovedFromRoomReducer: @escaping Reducer.ReducerType<ReceivedRemovedFromRoomAction, ChatState>) {
        self.userSubscriptionInitialStateReducer = userSubscriptionInitialStateReducer
        self.userSubscriptionRemovedFromRoomReducer = userSubscriptionRemovedFromRoomReducer
    }
    
    // MARK: - Internal methods
    
    func reduce(action: Action, state: ChatState) -> ChatState {
        if let action = action as? ReceivedInitialStateAction {
            return self.userSubscriptionInitialStateReducer(action, state)
        }
        else if let action = action as? ReceivedRemovedFromRoomAction {
            return self.userSubscriptionRemovedFromRoomReducer(action, state)
        }
        
        return state
    }
    
}
