
protocol HasReducer_Model_Rooms_forRemovedFromRoom {
    var reducer_model_rooms_forRemovedFromRoom:
        Reducer.Model.Rooms_forRemovedFromRoom.Typing.ExpressionType { get }
}

extension Reducer.Model {

    struct Rooms_forRemovedFromRoom {
        
        struct Typing: ReducerTyping {
            typealias ActionType = ReceivedRemovedFromRoomAction
            typealias StateType = RoomListState
            typealias DependenciesType = Any // No dependencies at present
        }

        typealias T = Typing

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            
            let rooms = state.rooms.filter { $0.identifier != action.event.roomIdentifier }

            return RoomListState(rooms: rooms)
        }
    }
    
}
