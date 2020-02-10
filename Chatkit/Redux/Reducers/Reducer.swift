
// For namespacing
struct Reducer {}

protocol ReducerTyping {
    associatedtype ActionType: Any
    associatedtype StateType: State
    associatedtype DependenciesType
    typealias ExpressionType = (ActionType, StateType, DependenciesType) -> StateType
}
