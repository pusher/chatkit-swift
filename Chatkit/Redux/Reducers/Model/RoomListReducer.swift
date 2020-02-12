
extension Reducer.Model {
    
    struct RoomList: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = Action
        typealias StateType = RoomListState
        typealias DependenciesType = NoDependencies
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            if let action = action as? ReceivedInitialStateAction {
                let rooms = action.event.rooms.reduce(into: [String : RoomState]()) {
                    $0[$1.identifier] = RoomState(identifier: $1.identifier,
                                                  name: $1.name,
                                                  isPrivate: $1.isPrivate,
                                                  pushNotificationTitle: $1.pushNotificationTitleOverride,
                                                  customData: $1.customData,
                                                  lastMessageAt: $1.lastMessageAt,
                                                  createdAt: $1.createdAt,
                                                  updatedAt: $1.updatedAt)
                }
                
                return RoomListState(rooms: rooms)
            }
            else if let action = action as? ReceivedRemovedFromRoomAction {
                let rooms = state.rooms.filter { $0.value.identifier != action.event.roomIdentifier }
                return RoomListState(rooms: rooms)
            }
            
            return state
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasRoomListReducer {
    
    var roomListReducer: Reducer.Model.RoomList.ExpressionType { get }
    
}
