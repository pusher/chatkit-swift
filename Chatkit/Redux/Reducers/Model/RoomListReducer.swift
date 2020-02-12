
extension Reducer.Model {
    
    struct RoomList: Reducing {
        
        // MARK: - Types
        
        typealias ActionType = Action
        typealias StateType = RoomListState
        typealias DependenciesType = NoDependencies
        
        // MARK: - Reducer
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            if let action = action as? InitialStateAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            else if let action = action as? RemovedFromRoomAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            else if let action = action as? ReadStateUpdatedAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            
            return state
        }
        
        // MARK: - Private methods
        
        private static func reduce(action: InitialStateAction, state: StateType, dependencies: DependenciesType) -> StateType {
            let readSummaries = action.event.readStates.reduce(into: [String : ReadSummaryState]()) {
                $0[$1.roomIdentifier] = ReadSummaryState(unreadCount: $1.unreadCount)
            }
            
            let rooms = action.event.rooms.reduce(into: [String : RoomState]()) {
                let readSummary = readSummaries[$1.identifier] ?? .empty
                
                $0[$1.identifier] = RoomState(identifier: $1.identifier,
                                              name: $1.name,
                                              isPrivate: $1.isPrivate,
                                              pushNotificationTitle: $1.pushNotificationTitleOverride,
                                              customData: $1.customData,
                                              lastMessageAt: $1.lastMessageAt,
                                              readSummary: readSummary,
                                              createdAt: $1.createdAt,
                                              updatedAt: $1.updatedAt)
            }
            
            return RoomListState(rooms: rooms)
        }
        
        private static func reduce(action: RemovedFromRoomAction, state: StateType, dependencies: DependenciesType) -> StateType {
            let rooms = state.rooms.filter { $0.value.identifier != action.event.roomIdentifier }
            return RoomListState(rooms: rooms)
        }
        
        private static func reduce(action: ReadStateUpdatedAction, state: StateType, dependencies: DependenciesType) -> StateType {
            guard let room = state.rooms[action.event.readState.roomIdentifier] else {
                return state
            }
            
            let readSummary = ReadSummaryState(unreadCount: action.event.readState.unreadCount)
            
            var rooms = state.rooms
            rooms[room.identifier] = RoomState(identifier: room.identifier,
                                               name: room.name,
                                               isPrivate: room.isPrivate,
                                               pushNotificationTitle: room.pushNotificationTitle,
                                               customData: room.customData,
                                               lastMessageAt: room.lastMessageAt,
                                               readSummary: readSummary,
                                               createdAt: room.createdAt,
                                               updatedAt: room.updatedAt)
            
            return RoomListState(rooms: rooms)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasRoomListReducer {
    
    var roomListReducer: Reducer.Model.RoomList.ExpressionType { get }
    
}
