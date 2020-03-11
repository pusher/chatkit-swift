
protocol State: Hashable {
    
    var isComplete: Bool { get }
    
    func supplement(withState supplementalState: Self) -> Self
    
}
