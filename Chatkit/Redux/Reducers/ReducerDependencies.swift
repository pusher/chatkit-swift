
// For namespacing the Concrete Reducer implementations
struct Reducer {
}

protocol ReducerDependencies:
    HasReducer_Master &
    HasReducer_Model_User_forInitialState &
    HasReducer_Model_Rooms_forInitialState &
    HasReducer_Model_Rooms_forRemovedFromRoom &
    HasReducer_UserSubscription_InitialState &
    HasReducer_UserSubscription_RemovedFromRoom
{}

struct ConcreteReducerDependencies: ReducerDependencies {
    let reducer_master = Reducer.Master.reduce
    let reducer_model_user_forInitialState = Reducer.Model.User_forInitialState.reduce
    let reducer_model_rooms_forInitialState = Reducer.Model.Rooms_forInitialState.reduce
    let reducer_model_rooms_forRemovedFromRoom = Reducer.Model.Rooms_forRemovedFromRoom.reduce
    let reducer_userSubscription_initialState = Reducer.UserSubscription.InitialState.reduce
    let reducer_userSubscription_removedFromRoom = Reducer.UserSubscription.RemovedFromRoom.reduce
}
