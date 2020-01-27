import Foundation

internal extension String {
    
    // MARK: - Internal methods
    
    func camelcased(separator: Character) -> String {
        return self.lowercased().split(separator: separator).enumerated().map { $0.offset > 0 ? $0.element.capitalized : String($0.element) }.joined()
    }
    
}
