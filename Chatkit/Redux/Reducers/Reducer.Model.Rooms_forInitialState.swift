
protocol HasReducer_Model_Rooms_forInitialState {
    var reducer_model_rooms_forInitialState:
        Reducer.Model.Rooms_forInitialState.Typing.ExpressionType { get }
}

extension Reducer.Model {

    struct Rooms_forInitialState: Reducing {
        
        struct Typing: ReducerTyping {
            typealias ActionType = ReceivedInitialStateAction
            typealias StateType = RoomListState
            typealias DependenciesType = Any // No dependencies at present
        }

        typealias T = Typing

        static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType {
            
            let rooms = action.event.rooms.map {
                RoomState(identifier: $0.identifier,
                          name: $0.name,
                          isPrivate: $0.isPrivate,
                          pushNotificationTitle: $0.pushNotificationTitleOverride,
                          customData: $0.customData,
                          lastMessageAt: $0.lastMessageAt,
                          createdAt: $0.createdAt,
                          updatedAt: $0.updatedAt)
            }
            
            return RoomListState(rooms: rooms)
        }
    }
    
}
