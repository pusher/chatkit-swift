
protocol ListState: State, Sequence, IteratorProtocol where Element == StateElement {
    
    associatedtype StateElement: State
    
    var elements: [String : StateElement] { get }
    var iteratorIndexes: [String] { get }
    var iteratorIndex: Int? { get set }
    
}

// MARK: - Iterator

extension ListState {
    
    mutating func next() -> StateElement? {
        let iteratorIndex = self.iteratorIndex ?? 0
        
        guard iteratorIndex < self.iteratorIndexes.endIndex else {
            return nil
        }
        
        self.iteratorIndex = iteratorIndex + 1
        
        let index = self.iteratorIndexes[iteratorIndex]
        
        return self.elements[index]
    }
    
}

// MARK: - Subscript

extension ListState {
    
    subscript(identifier: String) -> StateElement? {
        return self.elements[identifier]
    }
    
}
