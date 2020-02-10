
protocol HasReducer_Model_Rooms_forInitialState {
    var reducer_model_rooms_forInitialState: T.ReduceFunctionSignature { get }
}

extension HasReducer_Model_Rooms_forInitialState {
    typealias T = Reducer.Model.Rooms_forInitialState.Types
}

extension Reducer.Model {

    struct Rooms_forInitialState {
        
        struct Types: ReducerTypes {
            typealias ActionType = ReceivedInitialStateAction
            typealias StateType = RoomListState
            typealias DependenciesType = Any // No dependencies at present
        }

        typealias T = Types

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
