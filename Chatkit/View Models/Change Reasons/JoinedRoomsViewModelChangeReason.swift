
public extension JoinedRoomsViewModel {
    
    enum ChangeReason {
        
        case itemInserted(position: Int)
        case itemMoved(fromPosition: Int, toPosition: Int)
        case itemChanged(position: Int, previousValue: Room)
        case itemRemoved(position: Int, previousValue: Room)
        
        // MARK: - Initializers
        
        init?(repositoryChangeReason: JoinedRoomsRepository.ChangeReason?, currentRooms: [Room], previousRooms: [Room]?) {
            guard let repositoryChangeReason = repositoryChangeReason else {
                return nil
            }
            
            switch repositoryChangeReason {
            case let .addedToRoom(room):
                if let position = currentRooms.index(of: room) {
                    self = .itemInserted(position: position)
                    return
                }
                
            case let .removedFromRoom(room),
                 let .roomDeleted(room):
                if let position = previousRooms?.index(of: room) {
                    self = .itemRemoved(position: position, previousValue: room)
                    return
                }
                
            case let .roomUpdated(updatedRoom, previousValue),
                 let .readStateUpdated(updatedRoom, previousValue):
                if let currentPosition = currentRooms.index(of: updatedRoom) {
                    if let previousPosition = previousRooms?.index(of: previousValue), currentPosition != previousPosition {
                        self = .itemMoved(fromPosition: previousPosition, toPosition: currentPosition)
                        return
                    }
                    
                    self = .itemChanged(position: currentPosition, previousValue: previousValue)
                    return
                }
            }
            
            return nil
        }
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsViewModel.ChangeReason: Equatable {
    
    public static func == (lhs: JoinedRoomsViewModel.ChangeReason, rhs: JoinedRoomsViewModel.ChangeReason) -> Bool {
        switch (lhs, rhs) {
        case (let .itemInserted(lhsPosition),
              let .itemInserted(rhsPosition)):
            return lhsPosition == rhsPosition
            
        case (let .itemMoved(lhsFromPosition, lhsToPosition),
              let .itemMoved(rhsFromPosition, rhsToPosition)):
            return lhsFromPosition == rhsFromPosition && lhsToPosition == rhsToPosition
            
        case (let .itemChanged(lhsFromPosition, lhsPreviousValue),
              let .itemChanged(rhsFromPosition, rhsPreviousValue)),
             (let .itemRemoved(lhsFromPosition, lhsPreviousValue),
              let .itemRemoved(rhsFromPosition, rhsPreviousValue)):
            return lhsFromPosition == rhsFromPosition && lhsPreviousValue == rhsPreviousValue
            
        default:
            return false
        }
    }
    
}
