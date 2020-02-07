
struct Reducer {
    
    typealias ReducerType<ActionType: Action, StateType: State> = (ActionType, StateType) -> StateType
    
}
