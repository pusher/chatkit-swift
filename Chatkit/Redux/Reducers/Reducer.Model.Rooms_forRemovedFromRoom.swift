
protocol HasReducer_Model_Rooms_forRemovedFromRoom {

    var reducer_model_rooms_forRemovedFromRoom: (ActionType, StateType, DependenciesType) -> Self.StateType { get }
}

extension HasReducer_Model_Rooms_forRemovedFromRoom {
    typealias ActionType = ReceivedRemovedFromRoomAction
    typealias StateType = RoomListState
    typealias DependenciesType = Any // No dependencies at present
}

extension Reducer.Model {

    struct Rooms_forRemovedFromRoom {

        typealias T = HasReducer_Model_Rooms_forRemovedFromRoom

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            
            let rooms = state.rooms.filter { $0.identifier != action.event.roomIdentifier }

            return RoomListState(rooms: rooms)
        }
    }
    
}

//protocol HasReducer_Model_Rooms_forRemovedFromRoom {
//    var reducer_model_rooms_forRemovedFromRoom: (ReceivedRemovedFromRoomAction, RoomListState) -> RoomListState { get }
//}
//
//extension Reducer.Model {
//
//    static func rooms_forRemovedFromRoom(action: ReceivedRemovedFromRoomAction, state: RoomListState) -> RoomListState {
//        let rooms = state.rooms.filter { $0.identifier != action.event.roomIdentifier }
//
//        return RoomListState(rooms: rooms)
//    }
//}
