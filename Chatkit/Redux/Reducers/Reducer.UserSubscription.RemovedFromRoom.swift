
protocol HasReducer_UserSubscription_RemovedFromRoom {
    var reducer_userSubscription_removedFromRoom:
        Reducer.UserSubscription.RemovedFromRoom.ExpressionType { get }
}

extension Reducer.UserSubscription {
    
    struct RemovedFromRoom: Reducing {

        typealias ActionType = ReceivedRemovedFromRoomAction
        typealias StateType = ChatState
        typealias DependenciesType = HasReducer_Model_Rooms_forRemovedFromRoom
        
        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
            let joinedRooms = dependencies.reducer_model_rooms_forRemovedFromRoom(action, state.joinedRooms, dependencies)
            
            return ChatState(currentUser: state.currentUser, joinedRooms: joinedRooms)
        }
        
    }
    
}
