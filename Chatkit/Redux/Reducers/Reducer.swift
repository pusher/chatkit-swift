
// For namespacing
struct Reducer {}

protocol ReducerTypes {
    associatedtype ActionType: Any
    associatedtype StateType: State
    associatedtype DependenciesType
    typealias ReduceFunctionSignature = (ActionType, StateType, DependenciesType) -> StateType
}
