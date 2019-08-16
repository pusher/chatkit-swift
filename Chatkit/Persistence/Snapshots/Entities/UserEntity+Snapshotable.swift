import Foundation

extension UserEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = User
    
    // MARK: - Internal methods
    
    func snapshot() throws -> User {
        // TODO: Implement
        return User()
    }
    
}
