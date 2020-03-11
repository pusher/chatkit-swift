import Foundation

public extension JoinedRoomsViewModel {
    
    /// An enumeration representing the state of a `JoinedRoomsViewModel` which serves live data
    /// retrieved from the Chatkit web service.
    enum State {
        
        /// The case representing a connection to the Chatkit web service that is currently being
        /// established.
        ///
        /// - Parameters:
        ///     - error: An optional error describing the problem that occurred when trying
        ///     to establish a connection to the web service.
        case initializing(error: Error?)
        
        /// The case representing an open connection to the Chatkit web service.
        ///
        /// - Parameters:
        ///     - rooms: The array of all rooms joined by the user.
        ///     - changeReason: An optional change reason, describing the last change introduced
        ///     to the `state` of the view model.
        case connected(rooms: [Room], changeReason: ChangeReason?)
        
        /// The case representing a problem with the connection to the Chatkit web service.
        ///
        /// - Parameters:
        ///     - rooms: The array of all rooms joined by the user.
        ///     - error: Error describing the problem with the connection to the web service.
        ///     - changeReason: An optional change reason, describing the last change introduced
        ///     to the `state` of the view model.
        case degraded(rooms: [Room], error: Error, changeReason: ChangeReason?)
        
        /// The case representing a closed connection to the Chatkit web service.
        ///
        /// - Parameters:
        ///     - error: An optional error describing the problem that caused the connection
        ///     to the web service to close.
        case closed(error: Error?)
        
        // MARK: - Initializers
        
        internal init(repositoryState: JoinedRoomsRepositoryState, previousRooms: [Room]?) {
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
                if lhs.lastMessageAt == nil && rhs.lastMessageAt != nil {
                    return true
                }
                else if lhs.lastMessageAt != nil && rhs.lastMessageAt == nil {
                    return false
                }
                else if let lhsLastMessageAt = lhs.lastMessageAt, let rhsLastMessageAt = rhs.lastMessageAt {
                    return lhsLastMessageAt > rhsLastMessageAt
                }
                
                return lhs.createdAt > rhs.createdAt
            }
        }
        
    }
    
}

// MARK: - Equatable

extension JoinedRoomsViewModel.State: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
    public static func == (lhs: JoinedRoomsViewModel.State, rhs: JoinedRoomsViewModel.State) -> Bool {
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
