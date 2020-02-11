
protocol HasReducer_Model_Rooms_forRemovedFromRoom {
    var reducer_model_rooms_forRemovedFromRoom:
        Reducer.Model.Rooms_forRemovedFromRoom.ExpressionType { get }
}

extension Reducer.Model {

    struct Rooms_forRemovedFromRoom: Reducing {
        
        typealias ActionType = ReceivedRemovedFromRoomAction
        typealias StateType = [RoomState]
        typealias DependenciesType = Any // No dependencies at present

        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
            return state.filter { $0.identifier != action.event.roomIdentifier }

        }
    }
    
}
