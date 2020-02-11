
// For namespacing
struct Reducer {}

protocol Reducing {
    
    associatedtype ActionType: Action
    associatedtype StateType: State
    associatedtype DependenciesType
    
    typealias ExpressionType = (ActionType, StateType, DependenciesType) -> StateType
    
    static func reduce(action: ActionType, state: StateType, dependencies: DependenciesType) -> StateType
}
