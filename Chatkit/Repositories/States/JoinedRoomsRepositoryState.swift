
public extension JoinedRoomsRepository {
    
    enum State {
        
        case initializing(error: Error?)
        case connected(rooms: Set<Room>, changeReason: ChangeReason?)
        case degraded(rooms: Set<Room>, error: Error, changeReason: ChangeReason?)
        case closed(error: Error?)
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsRepository.State: Equatable {
    
    public static func == (lhs: JoinedRoomsRepository.State, rhs: JoinedRoomsRepository.State) -> Bool {
        switch (lhs, rhs) {
        case (let .initializing(lhsError as NSError?),
              let .initializing(rhsError as NSError?)),
             (let .closed(lhsError as NSError?),
              let .closed(rhsError as NSError?)):
            return lhsError == rhsError
            
        case (let .connected(lhsRooms, lhsChangeReason),
              let .connected(rhsRooms, rhsChangeReason)):
            return lhsRooms == rhsRooms && lhsChangeReason == rhsChangeReason
            
        case (let .degraded(lhsRooms, lhsError as NSError?, lhsChangeReason),
              let .degraded(rhsRooms, rhsError as NSError?, rhsChangeReason)):
            return lhsRooms == rhsRooms && lhsError == rhsError && lhsChangeReason == rhsChangeReason
            
        default:
            return false
        }
    }
    
}
