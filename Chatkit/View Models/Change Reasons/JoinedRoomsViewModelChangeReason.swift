
public extension JoinedRoomsViewModel {
    
    /// Enumeration that describes changes introduced to the state of `JoinedRoomsViewModel`.
    enum ChangeReason {
        
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
        
        internal init?(repositoryChangeReason: JoinedRoomsRepository.ChangeReason?, currentRooms: [Room], previousRooms: [Room]?) {
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
    
}

// MARK: - Equatable

extension JoinedRoomsViewModel.ChangeReason: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
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
