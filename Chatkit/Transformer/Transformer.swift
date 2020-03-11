
protocol Transformer {
    
    func transform(state: RoomState) -> Room
    func transform(currentState: VersionedState, previousState: VersionedState?) -> JoinedRoomsRepository.ChangeReason?
    
}

// MARK: - Concrete implementation

struct ConcreteTransformer: Transformer {
    
    // MARK: - Mapping
    
    func transform(state: RoomState) -> Room {
        return Room(identifier: state.identifier,
                    name: state.name,
                    isPrivate: state.isPrivate,
                    unreadCount: state.readSummary.unreadCount,
                    lastMessageAt: state.lastMessageAt,
                    customData: state.customData,
                    createdAt: state.createdAt,
                    updatedAt: state.updatedAt)
    }
    
    func transform(currentState: VersionedState, previousState: VersionedState?) -> JoinedRoomsRepository.ChangeReason? {
        switch currentState.signature {
        case let .addedToRoom(roomIdentifier):
            guard let currentRoom = self.room(fromState: currentState, forIdentifier: roomIdentifier) else {
                return nil
            }
            
            return .addedToRoom(room: currentRoom)
            
        case let .removedFromRoom(roomIdentifier):
            guard let currentRoom = self.room(fromState: currentState, forIdentifier: roomIdentifier) else {
                return nil
            }
            
            return .removedFromRoom(room: currentRoom)
            
        case let .roomUpdated(roomIdentifier):
            guard let currentRoom = self.room(fromState: currentState, forIdentifier: roomIdentifier),
                let previousRoom = self.room(fromState: previousState, forIdentifier: roomIdentifier) else {
                    return nil
            }
            
            return .roomUpdated(updatedRoom: currentRoom, previousValue: previousRoom)
            
        case let .roomDeleted(roomIdentifier):
            guard let previousRoom = self.room(fromState: previousState, forIdentifier: roomIdentifier) else {
                return nil
            }
            
            return .roomDeleted(room: previousRoom)
            
        case let .readStateUpdated(roomIdentifier):
            guard let currentRoom = self.room(fromState: currentState, forIdentifier: roomIdentifier),
                let previousRoom = self.room(fromState: previousState, forIdentifier: roomIdentifier) else {
                    return nil
            }
            
            return .readStateUpdated(updatedRoom: currentRoom, previousValue: previousRoom)
            
        case .unsigned,
             .initialState,
             .subscriptionStateUpdated:
            return nil
        }
    }
    
    // MARK: - Private methods
    
    private func room(fromState state: VersionedState?, forIdentifier identifier: String) -> Room? {
        guard let state = state,
            let roomState = state.chatState.joinedRooms[identifier] else {
                return nil
        }
        
        return transform(state: roomState)
    }
    
}

// MARK: - Dependencies

protocol HasTransformer {
    
    var transformer: Transformer { get }
    
}
