import Foundation

struct InstanceLocator {
    
    // MARK: - Properties
    
    private static let separator: Character = ":"
    
    let region: String
    let identifier: String
    let version: String
    
    // MARK: - Initializers
    
    init(_ instanceLocator: String) throws {
        let components = instanceLocator.split(separator: InstanceLocator.separator)
        
        guard components.count == 3 else {
            throw NetworkingError.invalidInstanceLocator
        }
        
        self.region = String(components[1])
        self.identifier = String(components[2])
        self.version = String(components[0])
    }
    
}
