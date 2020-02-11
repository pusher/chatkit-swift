
protocol HasReducer_Model_Rooms_forInitialState {
    var reducer_model_rooms_forInitialState:
        Reducer.Model.Rooms_forInitialState.ExpressionType { get }
}

extension Reducer.Model {

    struct Rooms_forInitialState: Reducing {
        
        typealias ActionType = ReceivedInitialStateAction
        typealias StateType = [RoomState]
        typealias DependenciesType = Any // No dependencies at present

        static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType {
            
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
    }
    
}
