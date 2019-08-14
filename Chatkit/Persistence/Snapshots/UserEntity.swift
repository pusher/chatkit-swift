import Foundation

extension UserEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = User
    
    // MARK: - Methods
    
    func snapshot() -> User {
        // TODO: Implement
        return User()
    }
    
}
