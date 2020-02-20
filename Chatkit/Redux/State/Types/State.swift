
protocol State {
    
    var isComplete: Bool { get }
    
    func supplement(withState supplementalState: Self) -> Self
    
}
