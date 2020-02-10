
protocol HasReducer_Model_Rooms_forInitialState {
    var reducer_model_rooms_forInitialState: (ActionType, StateType, DependenciesType) -> Self.StateType { get }
}

extension HasReducer_Model_Rooms_forInitialState {
    typealias ActionType = ReceivedInitialStateAction
    typealias StateType = RoomListState
    typealias DependenciesType = Any // No dependencies at present
}

extension Reducer.Model {

    struct Rooms_forInitialState {

        typealias T = HasReducer_Model_Rooms_forInitialState

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

//protocol HasReducer_Model_Rooms_forInitialState {
//    var reducer_model_rooms_forInitialState: (ReceivedInitialStateAction, RoomListState) -> RoomListState { get }
//}
//
//extension Reducer.Model {
//
//    static func rooms_forInitialState(action: ReceivedInitialStateAction, state: RoomListState) -> RoomListState {
//        let rooms = action.event.rooms.map {
//            RoomState(identifier: $0.identifier,
//                      name: $0.name,
//                      isPrivate: $0.isPrivate,
//                      pushNotificationTitle: $0.pushNotificationTitleOverride,
//                      customData: $0.customData,
//                      lastMessageAt: $0.lastMessageAt,
//                      createdAt: $0.createdAt,
//                      updatedAt: $0.updatedAt)
//        }
//
//        return RoomListState(rooms: rooms)
//    }
//}
