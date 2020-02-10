
// For namespacing
struct Reducer {}

protocol ReducerTypes {
    associatedtype ActionType: Any
    associatedtype StateType: State
    associatedtype DependenciesType
    typealias ExpressionType = (ActionType, StateType, DependenciesType) -> StateType
}
