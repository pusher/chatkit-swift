
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
            else if let action = action as? AddedToRoomAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            else if let action = action as? RemovedFromRoomAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            else if let action = action as? RoomUpdatedAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            else if let action = action as? RoomDeletedAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            else if let action = action as? ReadStateUpdatedAction {
                return self.reduce(action: action, state: state, dependencies: dependencies)
            }
            
            return state
        }
        
        // MARK: - Private reducers
        
        private static func reduce(action: InitialStateAction, state: StateType, dependencies: DependenciesType) -> StateType {
            let readSummaries = action.event.readStates.reduce(into: [String : ReadSummaryState]()) {
                $0[$1.roomIdentifier] = ReadSummaryState(unreadCount: $1.unreadCount)
            }
            
            let rooms: [RoomState] = action.event.rooms.map {
                let readSummary = readSummaries[$0.identifier] ?? .empty
                
                return RoomState(identifier: $0.identifier,
                                 name: $0.name,
                                 isPrivate: $0.isPrivate,
                                 pushNotificationTitle: $0.pushNotificationTitleOverride,
                                 customData: $0.customData,
                                 lastMessageAt: $0.lastMessageAt,
                                 readSummary: readSummary,
                                 createdAt: $0.createdAt,
                                 updatedAt: $0.updatedAt)
            }
            
            return RoomListState(elements: rooms)
        }
        
        private static func reduce(action: RemovedFromRoomAction, state: StateType, dependencies: DependenciesType) -> StateType {
            return self.deleteRoom(identifier: action.event.roomIdentifier, from: state)
        }
        
        private static func reduce(action: AddedToRoomAction, state: StateType, dependencies: DependenciesType) -> StateType {
            let room = RoomState(identifier: action.event.room.identifier,
                                 name: action.event.room.name,
                                 isPrivate: action.event.room.isPrivate,
                                 pushNotificationTitle: action.event.room.pushNotificationTitleOverride,
                                 customData: action.event.room.customData,
                                 lastMessageAt: action.event.room.lastMessageAt,
                                 readSummary: ReadSummaryState(unreadCount: action.event.readState.unreadCount),
                                 createdAt: action.event.room.createdAt,
                                 updatedAt: action.event.room.updatedAt)
            
            var rooms = state.elements
            rooms[room.identifier] = room
            
            return RoomListState(elements: rooms)
        }
        
        private static func reduce(action: RoomDeletedAction, state: StateType, dependencies: DependenciesType) -> StateType {
            return self.deleteRoom(identifier: action.event.roomIdentifier, from: state)
        }
        
        private static func reduce(action: RoomUpdatedAction, state: StateType, dependencies: DependenciesType) -> StateType {
            guard let currentRoom = state[action.event.room.identifier] else {
                return state
            }
            
            let updatedRoom = RoomState(identifier: action.event.room.identifier,
                                        name: action.event.room.name,
                                        isPrivate: action.event.room.isPrivate,
                                        pushNotificationTitle: action.event.room.pushNotificationTitleOverride,
                                        customData: action.event.room.customData,
                                        lastMessageAt: action.event.room.lastMessageAt,
                                        readSummary: currentRoom.readSummary,
                                        createdAt: action.event.room.createdAt,
                                        updatedAt: action.event.room.updatedAt)
            
            var updatedRooms = state.elements
            updatedRooms[updatedRoom.identifier] = updatedRoom
            
            return RoomListState(elements: updatedRooms)
        }
        
        private static func reduce(action: ReadStateUpdatedAction, state: StateType, dependencies: DependenciesType) -> StateType {
            guard let room = state[action.event.readState.roomIdentifier] else {
                return state
            }
            
            let readSummary = ReadSummaryState(unreadCount: action.event.readState.unreadCount)
            
            var rooms = state.elements
            rooms[room.identifier] = RoomState(identifier: room.identifier,
                                               name: room.name,
                                               isPrivate: room.isPrivate,
                                               pushNotificationTitle: room.pushNotificationTitle,
                                               customData: room.customData,
                                               lastMessageAt: room.lastMessageAt,
                                               readSummary: readSummary,
                                               createdAt: room.createdAt,
                                               updatedAt: room.updatedAt)
            
            return RoomListState(elements: rooms)
        }
        
        // MARK: - Private methods
        
        private static func deleteRoom(identifier: String, from state: RoomListState) -> RoomListState {
            let rooms = state.filter { $0.identifier != identifier }
            return RoomListState(elements: rooms)
        }
        
    }
    
}

// MARK: - Dependencies

protocol HasRoomListReducer {
    
    var roomListReducer: Reducer.Model.RoomList.ExpressionType { get }
    
}
