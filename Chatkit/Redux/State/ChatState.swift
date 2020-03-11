
struct ChatState: State {
    
    // MARK: - Properties
    
    let currentUser: UserState
    let joinedRooms: RoomListState
    
    let users: UserListState
    
    // TODO: Add cursors.
    // TODO: Add memberships.
    
    static let empty: ChatState = ChatState(currentUser: .empty, joinedRooms: .empty, users: .empty)
    
    // MARK: - Accessors
    
    var isComplete: Bool {
        return self.currentUser.isComplete
            && self.joinedRooms.isComplete
            && self.users.isComplete
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: ChatState) -> ChatState {
        let currentUser = self.currentUser.supplement(withState: supplementalState.currentUser)
        let joinedRooms = self.joinedRooms.supplement(withState: supplementalState.joinedRooms)
        let users = self.users.supplement(withState: supplementalState.users)
        
        return ChatState(currentUser: currentUser,
                         joinedRooms: joinedRooms,
                         users: users)
    }
    
}
