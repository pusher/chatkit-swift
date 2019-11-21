import Foundation

extension UserEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = User
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? {
        return nil
    }
    
    // MARK: - Internal methods
    
    func snapshot() throws -> User {
        var avatar: URL? = nil
        if let avatarURLString = self.avatar {
            avatar = URL(string: avatarURLString)
        }
        
        let presenceState = PresenceState(state: self.presenceState)
        let customData = CustomDataSerializer.deserialize(data: self.customData)
        
        return User(identifier: self.identifier,
                    name: self.name,
                    avatar: avatar,
                    presenceState: presenceState,
                    customData: customData,
                    createdAt: self.createdAt,
                    updatedAt: self.updatedAt,
                    objectID: self.objectID)
    }
    
}
