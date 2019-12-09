import Foundation

internal extension IndexSet {
    
    // MARK: - Properties
    
    var isContiguous: Bool {
        guard let max = self.max(), let min = self.min() else {
            return true
        }
        
        return max - min + 1 == self.count
    }
    
}
