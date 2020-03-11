
internal extension JoinedRoomsRepository {
    
    struct Filter: StateFilter {
        
        // MARK: - Internal methods
        
        func hasModifiedSubstate(oldState: VersionedState, newState: VersionedState) -> Bool {
            return newState.chatState.joinedRooms != oldState.chatState.joinedRooms
        }
        
        func hasCompleteSubstate(_ state: VersionedState) -> Bool {
            return state.chatState.joinedRooms.isComplete
        }
        
        func hasRelevantSignature(_ signature: VersionSignature) -> Bool {
            switch signature {
            case .initialState,
                 .addedToRoom,
                 .removedFromRoom,
                 .roomUpdated,
                 .roomDeleted,
                 .readStateUpdated:
                return true
                
            case .unsigned,
                 .subscriptionStateUpdated:
                return false
            }
        }
        
    }
    
}
