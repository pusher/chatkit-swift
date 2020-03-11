
/// Enumeration that describes changes introduced to the state of `JoinedRoomsRepository`.
public enum JoinedRoomsRepositoryChangeReason {
    
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

// MARK: - Equatable

extension JoinedRoomsRepositoryChangeReason: Equatable {}
