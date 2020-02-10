
protocol HasReducer_Model_Rooms_forRemovedFromRoom {
    var reducer_model_rooms_forRemovedFromRoom:T.ExpressionType { get }
}

extension HasReducer_Model_Rooms_forRemovedFromRoom {
    typealias T = Reducer.Model.Rooms_forRemovedFromRoom.Types
}

extension Reducer.Model {

    struct Rooms_forRemovedFromRoom {
        
        struct Types: ReducerTyping {
            typealias ActionType = ReceivedRemovedFromRoomAction
            typealias StateType = RoomListState
            typealias DependenciesType = Any // No dependencies at present
        }

        typealias T = Types

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            
            let rooms = state.rooms.filter { $0.identifier != action.event.roomIdentifier }

            return RoomListState(rooms: rooms)
        }
    }
    
}
