
// For namespacing
struct Reducer {}

protocol ReducerTyping {
    associatedtype ActionType: Any
    associatedtype StateType: State
    associatedtype DependenciesType
    typealias ExpressionType = (ActionType, StateType, DependenciesType) -> StateType
}

protocol Reducing {
    associatedtype T: ReducerTyping
    static func reduce(action: T.ActionType, state: T.StateType, dependencies: T.DependenciesType) -> T.StateType
}
