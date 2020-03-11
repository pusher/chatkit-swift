
/// Enumeration that describes changes introduced to the state of `JoinedRoomsViewModel`.
public enum JoinedRoomsViewModelChangeReason {
    
    /// Notifies the receiver that a new room has been added to the maintened collection of rooms.
    ///
    /// - Parameters:
    ///     - position: The index of the added room in the maintened collection of rooms.
    case itemInserted(position: Int)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been moved.
    ///
    /// - Parameters:
    ///     - fromPosition: The old index of the room before the move.
    ///     - toPosition: The new index of the room after the move.
    case itemMoved(fromPosition: Int, toPosition: Int)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been changed.
    ///
    /// - Parameters:
    ///     - position: The index of the changed room in the maintened collection of rooms.
    ///     - previousValue: The value of the room befrore it was updated.
    case itemChanged(position: Int, previousValue: Room)
    
    /// Notifies the receiver that a room from the maintened collection of rooms has been removed.
    ///
    /// - Parameters:
    ///     - position: The index of the removed room in the maintened collection of rooms.
    ///     - previousValue: The value of the room befrore it was removed.
    case itemRemoved(position: Int, previousValue: Room)
    
    // MARK: - Initializers
    
    internal init?(repositoryChangeReason: JoinedRoomsRepositoryChangeReason?, currentRooms: [Room], previousRooms: [Room]?) {
        guard let repositoryChangeReason = repositoryChangeReason else {
            return nil
        }
        
        switch repositoryChangeReason {
        case let .addedToRoom(room):
            if let position = currentRooms.firstIndex(of: room) {
                self = .itemInserted(position: position)
                return
            }
            
        case let .removedFromRoom(room),
             let .roomDeleted(room):
            if let position = previousRooms?.firstIndex(of: room) {
                self = .itemRemoved(position: position, previousValue: room)
                return
            }
            
        case let .roomUpdated(updatedRoom, previousValue),
             let .readStateUpdated(updatedRoom, previousValue):
            if let currentPosition = currentRooms.firstIndex(of: updatedRoom) {
                if let previousPosition = previousRooms?.firstIndex(of: previousValue), currentPosition != previousPosition {
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

// MARK: - Equatable

extension JoinedRoomsViewModelChangeReason: Equatable {}
