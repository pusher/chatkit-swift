
public extension JoinedRoomsRepository {
    
    enum ChangeReason {
        
        case addedToRoom(room: Room)
        case removedFromRoom(room: Room)
        case roomUpdated(updatedRoom: Room, previousValue: Room)
        case readStateUpdated(updatedRoom: Room, previousValue: Room)
        case roomDeleted(room: Room)
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsRepository.ChangeReason: Equatable {
    
    public static func == (lhs: JoinedRoomsRepository.ChangeReason, rhs: JoinedRoomsRepository.ChangeReason) -> Bool {
        switch (lhs, rhs) {
        case (let .addedToRoom(lhsRoom),
              let .addedToRoom(rhsRoom)),
             (let .removedFromRoom(lhsRoom),
              let .removedFromRoom(rhsRoom)),
             (let .roomDeleted(lhsRoom),
              let .roomDeleted(rhsRoom)):
            return lhsRoom == rhsRoom
            
        case (let .roomUpdated(lhsUpdatedRoom, lhsPreviousValue),
              let .roomUpdated(rhsUpdatedRoom, rhsPreviousValue)),
             (let .readStateUpdated(lhsUpdatedRoom, lhsPreviousValue),
              let .readStateUpdated(rhsUpdatedRoom, rhsPreviousValue)):
            return lhsUpdatedRoom == rhsUpdatedRoom && lhsPreviousValue == rhsPreviousValue
            
        default:
            return false
        }
    }
    
}
