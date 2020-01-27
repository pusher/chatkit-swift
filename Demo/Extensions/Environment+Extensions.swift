import Foundation
import Environment

// MARK: - Validation

internal extension Environment {
    
    // MARK: - Internal methods
    
    static func validate() {
        // This will trigger precondition check in Environment framework. In case of a failurel, the error will be highlighted in the same file in which the variable is defined which should be helpful for other developers.
        _ = Environment.instanceLocator
    }
    
}
