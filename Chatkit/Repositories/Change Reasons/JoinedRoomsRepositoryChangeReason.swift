
public extension JoinedRoomsRepository {
    
    /// Enumeration that describes changes introduced to the state of `JoinedRoomsRepository`.
    enum ChangeReason {
        
        /// Notifies the receiver that the current user has been added to a room.
        ///
        /// - Parameters:
        ///     - room: The room joined by the user.
        case addedToRoom(room: Room)
        
        /// Notifies the receiver that the current user has been removed from a room.
        ///
        /// - Parameters:
        ///     - room: The room which the user is no longer a member of.
        case removedFromRoom(room: Room)
        
        /// Notifies the receiver that a room the current user is a member of has been updated.
        ///
        /// - Parameters:
        ///     - updatedRoom: The new value of the room.
        ///     - previousValue: The value of the room befrore it was updated.
        case roomUpdated(updatedRoom: Room, previousValue: Room)
        
        /// Notifies the receiver that a read state summary of a room the current user is a member of has been updated.
        ///
        /// - Parameters:
        ///     - updatedRoom: The new value of the room.
        ///     - previousValue: The value of the room befrore it was updated.
        case readStateUpdated(updatedRoom: Room, previousValue: Room)
        
        /// Notifies the receiver that a room has been deleted.
        ///
        /// - Parameters:
        ///     - room: The room which the user is no longer a member of.
        case roomDeleted(room: Room)
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsRepository.ChangeReason: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
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
