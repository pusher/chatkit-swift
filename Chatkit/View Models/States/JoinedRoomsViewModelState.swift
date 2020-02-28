
public extension JoinedRoomsViewModel {
    
    enum State {
        
        case initializing(error: Error?)
        case connected(rooms: [Room], changeReason: ChangeReason?)
        case degraded(rooms: [Room], error: Error, changeReason: ChangeReason?)
        case closed(error: Error?)
        
        // MARK: - Initializers
        
        init(repositoryState: JoinedRoomsRepository.State, previousRooms: [Room]?) {
            switch repositoryState {
            case let .initializing(error):
                self = .initializing(error: error)
                
            case let .connected(rooms, repositoryChangeReason):
                let sortedRooms = State.sortedRooms(rooms)
                let changeReason = ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: sortedRooms, previousRooms: previousRooms)
                
                self = .connected(rooms: sortedRooms, changeReason: changeReason)
                
            case let .degraded(rooms, error, repositoryChangeReason):
                let sortedRooms = State.sortedRooms(rooms)
                let changeReason = ChangeReason(repositoryChangeReason: repositoryChangeReason, currentRooms: sortedRooms, previousRooms: previousRooms)
                
                self = .degraded(rooms: sortedRooms, error: error, changeReason: changeReason)
                
            case let .closed(error):
                self = .closed(error: error)
            }
        }
        
        // MARK: - Private methods
        
        private static func sortedRooms(_ rooms: Set<Room>) -> [Room] {
            return rooms.sorted { lhs, rhs -> Bool in
                if let lhsLastMessageAt = lhs.lastMessageAt, let rhsLastMessageAt = rhs.lastMessageAt {
                    return lhsLastMessageAt > rhsLastMessageAt
                }
                else {
                    return lhs.createdAt > rhs.createdAt
                }
            }
        }
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsViewModel.State: Equatable {
    
    public static func == (lhs: JoinedRoomsViewModel.State, rhs: JoinedRoomsViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (let .connected(lhsRooms, lhsChangeReason),
              let .connected(rhsRooms, rhsChangeReason)):
            return lhsRooms == rhsRooms && lhsChangeReason == rhsChangeReason
            
        case (let .degraded(lhsRooms, lhsError as NSError?, lhsChangeReason),
              let .degraded(rhsRooms, rhsError as NSError?, rhsChangeReason)):
            return lhsRooms == rhsRooms && lhsError == rhsError && lhsChangeReason == rhsChangeReason
            
        case (let .closed(lhsError as NSError?),
              let .closed(rhsError as NSError?)):
            return lhsError == rhsError
            
        default:
            return false
        }
    }
    
}
