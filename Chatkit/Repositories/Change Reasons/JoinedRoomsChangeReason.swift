
public extension JoinedRoomsRepository {
    
    enum ChangeReason {
        
        case joinedRoom(room: Room)
        case roomUpdated(updatedRoom: Room, previousValue: Room)
        case leftRoom(room: Room)
        case roomDeleted(room: Room)
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsRepository.ChangeReason: Equatable {
    
    public static func == (lhs: JoinedRoomsRepository.ChangeReason, rhs: JoinedRoomsRepository.ChangeReason) -> Bool {
        switch (lhs, rhs) {
        case (let .joinedRoom(lhsRoom),
              let .joinedRoom(rhsRoom)),
             (let .leftRoom(lhsRoom),
              let .leftRoom(rhsRoom)),
             (let .roomDeleted(lhsRoom),
              let .roomDeleted(rhsRoom)):
            return lhsRoom == rhsRoom
            
        case (let .roomUpdated(lhsUpdatedRoom, lhsPreviousValue),
              let .roomUpdated(rhsUpdatedRoom, rhsPreviousValue)):
            return lhsUpdatedRoom == rhsUpdatedRoom && lhsPreviousValue == rhsPreviousValue
            
        default:
            return false
        }
    }
    
}
