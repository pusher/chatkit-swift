
protocol HasReducer_UserSubscription_RemovedFromRoom {
    var reducer_userSubscription_removedFromRoom: T.ExpressionType { get }
}

extension HasReducer_UserSubscription_RemovedFromRoom {
    typealias T = Reducer.UserSubscription.RemovedFromRoom.Types
}

extension Reducer.UserSubscription {
    
    struct RemovedFromRoom {

        struct Types: ReducerTyping {
            typealias ActionType = ReceivedRemovedFromRoomAction
            typealias StateType = ChatState
            typealias DependenciesType = HasReducer_Model_Rooms_forRemovedFromRoom
        }

        typealias T = Types

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            
            let joinedRooms = dependencies.reducer_model_rooms_forRemovedFromRoom(action, state.joinedRooms, dependencies)
            
            return ChatState(currentUser: state.currentUser, joinedRooms: joinedRooms)
        }
    }
    
}
