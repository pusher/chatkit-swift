
extension Reducer.Model {
    
    struct Rooms: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = Action
        typealias StateType = [RoomState]
        typealias DependenciesType = NoDependencies
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            if let action = action as? ReceivedInitialStateAction {
                return action.event.rooms.map {
                    RoomState(identifier: $0.identifier,
                              name: $0.name,
                              isPrivate: $0.isPrivate,
                              pushNotificationTitle: $0.pushNotificationTitleOverride,
                              customData: $0.customData,
                              lastMessageAt: $0.lastMessageAt,
                              createdAt: $0.createdAt,
                              updatedAt: $0.updatedAt)
                }
            }
            else if let action = action as? ReceivedRemovedFromRoomAction {
                return state.filter { $0.identifier != action.event.roomIdentifier }
            }
            
            return state
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasRoomsReducer {
    
    var roomsReducer: Reducer.Model.Rooms.ExpressionType { get }
    
}
