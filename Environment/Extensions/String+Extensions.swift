import Foundation

internal extension String {
    
    // MARK: - Internal methods
    
    func camelcased(separator: Character) -> String {
        return self.split(separator: separator)
            .map { return $0.lowercased().capitalizingFirstLetter() }
            .joined()
    }
    
    func hungarianCased(separator: Character) -> String {
        return self.camelcased(separator: separator).lowercasingFirstLetter()
    }
    
    // MARK: - Private methods
    
    private func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    private func lowercasingFirstLetter() -> String {
        return prefix(1).lowercased() + dropFirst()
    }
    
}
