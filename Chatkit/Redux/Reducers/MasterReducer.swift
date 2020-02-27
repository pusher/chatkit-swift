
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
            let reducedChatState: ChatState
            let reducedAuxiliaryState: AuxiliaryState
            let signature: VersionSignature
            
            if let action = action as? InitialStateAction {
                reducedChatState = dependencies.initialStateUserSubscriptionReducer(action, state.chatState, dependencies)
                reducedAuxiliaryState = state.auxiliaryState
                signature = .initialState
            }
            else if let action = action as? AddedToRoomAction {
                reducedChatState = dependencies.userSubscriptionAddedToRoomReducer(action, state.chatState, dependencies)
                reducedAuxiliaryState = state.auxiliaryState
                signature = .addedToRoom
            }
            else if let action = action as? RemovedFromRoomAction {
                reducedChatState = dependencies.userSubscriptionRemovedFromRoomReducer(action, state.chatState, dependencies)
                reducedAuxiliaryState = state.auxiliaryState
                signature = .removedFromRoom
            }
            else if let action = action as? RoomUpdatedAction {
                reducedChatState = dependencies.userSubscriptionRoomUpdatedReducer(action, state.chatState, dependencies)
                reducedAuxiliaryState = state.auxiliaryState
                signature = .roomUpdated
            }
            else if let action = action as? RoomDeletedAction {
                reducedChatState = dependencies.userSubscriptionRoomDeletedReducer(action, state.chatState, dependencies)
                reducedAuxiliaryState = state.auxiliaryState
                signature = .roomDeleted
            }
            else if let action = action as? ReadStateUpdatedAction {
                reducedChatState = dependencies.userSubscriptionReadStateUpdatedReducer(action, state.chatState, dependencies)
                reducedAuxiliaryState = state.auxiliaryState
                signature = .readStateUpdated
            }
            else {
                return state
            }
            
            if reducedChatState != state.chatState || reducedAuxiliaryState != state.auxiliaryState {
                let version = state.version + 1
                
                return VersionedState(chatState: reducedChatState, auxiliaryState: reducedAuxiliaryState, version: version, signature: signature)
            }
            
            return state
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasMasterReducer {
    
    var masterReducer: Reducer.Master.ExpressionType { get }
    
}
