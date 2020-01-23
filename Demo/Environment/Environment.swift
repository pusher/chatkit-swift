import Foundation

struct Environment {
    
    // MARK: - Properties
    
    static let instanceLocator: String = "<UNSPECIFIED>"
    
}

// MARK: - Validation

extension Environment {
    
    // MARK: - Internal methods
    
    static func validate() {
        assert(Environment.instanceLocator != "<UNSPECIFIED>", "Please provide above your instance locator in order to run the app. You can find your instance locator Credentials tab of your Dashboard.")
    }
    
}
