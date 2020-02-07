
extension Reducer {
    
    struct Model {
        
        // MARK: - Reducers
        
        static func user(action: ReceivedInitialStateAction, state: UserState) -> UserState {
            return .populated(identifier: action.event.currentUser.identifier, name: action.event.currentUser.name)
        }
        
        static func roomList(action: ReceivedInitialStateAction, state: [RoomState]) -> [RoomState] {
            return action.event.rooms.map {
                RoomState(identifier: $0.identifier,
                          name: $0.name,
                          isPrivate: $0.isPrivate,
                          pushNotificationTitle: $0.pushNotificationTitleOverride,
                          customData: $0.customData,
                          lastMessageAt: $0.lastMessageAt,
                          createdAt: $0.createdAt,
                          updatedAt: $0.updatedAt)
            }
        }
        
        static func roomList(action: ReceivedRemovedFromRoomAction, state: [RoomState]) -> [RoomState] {
            return state.filter { $0.identifier != action.event.roomIdentifier }
        }
        
    }
    
}
