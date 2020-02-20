
protocol Transformer {
    
    associatedtype InputState: State
    associatedtype OutputModel: Model
    
    static func transform(state: InputState) -> OutputModel
    
}
