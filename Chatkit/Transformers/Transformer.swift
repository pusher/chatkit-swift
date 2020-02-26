
protocol Transformer {
    
    associatedtype InputState: State
    associatedtype OutputModel: Model
    
    func transform(state: InputState) -> OutputModel
    
}
