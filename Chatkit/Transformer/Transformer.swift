
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
        var identifier: String? = nil
        
        switch currentState.signature {
        case let .addedToRoom(roomIdentifier),
             let .removedFromRoom(roomIdentifier),
             let .roomUpdated(roomIdentifier),
             let .roomDeleted(roomIdentifier),
             let .readStateUpdated(roomIdentifier):
            identifier = roomIdentifier
            
        case .unsigned,
             .initialState,
             .subscriptionStateUpdated:
            break
        }
        
        guard let roomIdentifier = identifier,
            let currentRoomState = currentState.chatState.joinedRooms[roomIdentifier] else {
                return nil
        }
        
        let currentRoom: Room = self.transform(state: currentRoomState)
        var previousRoom: Room? = nil
        
        if let previousState = previousState,
            let previousRoomState = previousState.chatState.joinedRooms[roomIdentifier] {
            previousRoom = self.transform(state: previousRoomState)
        }
        
        switch currentState.signature {
        case .addedToRoom(_):
            return .addedToRoom(room: currentRoom)
            
        case .removedFromRoom(_):
            return .removedFromRoom(room: currentRoom)
            
        case .roomUpdated(_):
            if let previousRoom = previousRoom {
                return .roomUpdated(updatedRoom: currentRoom, previousValue: previousRoom)
            }
            else {
                return nil
            }
            
        case .roomDeleted(_):
            return .roomDeleted(room: currentRoom)
            
        case .readStateUpdated(_):
            if let previousRoom = previousRoom {
                return .readStateUpdated(updatedRoom: currentRoom, previousValue: previousRoom)
            }
            else {
                return nil
            }
            
        case .unsigned,
             .initialState,
             .subscriptionStateUpdated:
            return nil
        }
    }
    
}

// MARK: - Dependencies

protocol HasTransformer {
    
    var transformer: Transformer { get }
    
}