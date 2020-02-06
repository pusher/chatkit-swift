
struct Reducer {
    
    typealias ReducerType<StateType: State> = (Action, StateType) -> StateType
    
}
