
extension Reducer {
    
    struct Master: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = Action
        typealias StateType = VersionedState
        typealias DependenciesType =
            HasUserReducer
            & HasRoomListReducer
            & HasUserSubscriptionInitialStateReducer
            & HasUserSubscriptionAddedToRoomReducer
            & HasUserSubscriptionRemovedFromRoomReducer
            & HasUserSubscriptionRoomUpdatedReducer
            & HasUserSubscriptionRoomDeletedReducer
            & HasUserSubscriptionReadStateUpdatedReducer
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            let reducedState: ChatState
            let signature: VersionSignature
            
            if let action = action as? InitialStateAction {
                reducedState = dependencies.initialStateUserSubscriptionReducer(action, state.chatState, dependencies)
                signature = .initialState
            }
            else if let action = action as? AddedToRoomAction {
                reducedState = dependencies.userSubscriptionAddedToRoomReducer(action, state.chatState, dependencies)
                signature = .addedToRoom
            }
            else if let action = action as? RemovedFromRoomAction {
                reducedState = dependencies.userSubscriptionRemovedFromRoomReducer(action, state.chatState, dependencies)
                signature = .removedFromRoom
            }
            else if let action = action as? RoomUpdatedAction {
                reducedState = dependencies.userSubscriptionRoomUpdatedReducer(action, state.chatState, dependencies)
                signature = .roomUpdated
            }
            else if let action = action as? RoomDeletedAction {
                reducedState = dependencies.userSubscriptionRoomDeletedReducer(action, state.chatState, dependencies)
                signature = .roomDeleted
            }
            else if let action = action as? ReadStateUpdatedAction {
                reducedState = dependencies.userSubscriptionReadStateUpdatedReducer(action, state.chatState, dependencies)
                signature = .readStateUpdated
            }
            else {
                return state
            }
            
            if reducedState != state.chatState {
                let version = state.version + 1
                
                return VersionedState(chatState: reducedState, version: version, signature: signature)
            }
            
            return state
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasMasterReducer {
    
    var masterReducer: Reducer.Master.ExpressionType { get }
    
}
