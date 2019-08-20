import Foundation

extension RoomEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Room
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Room {
        let creator = try self.creator.snapshot()
        let lastMessage = self.messages?.lastObject as? Message
        let members = snapshot(self.members)
        let typingMembers = snapshot(self.typingMembers)
        let metadata = (try? MetadataParser.deserialize(data: self.metadata)) ?? nil
        
        return Room(identifier: self.identifier,
                    name: self.name,
                    isPrivate: self.isPrivate,
                    creator: creator,
                    members: members,
                    typingMembers: typingMembers,
                    unreadCount: self.unreadCount,
                    lastMessage: lastMessage,
                    metadata: metadata,
                    createdAt: self.createdAt,
                    updatedAt: self.updatedAt,
                    deletedAt: self.deletedAt,
                    objectID: self.objectID)
    }
    
    // MARK: - Private methods
    
    private func snapshot(_ members: Set<UserEntity>?) -> Set<User>? {
        guard let snapshot = (members?.compactMap { try? $0.snapshot() }) else {
            return nil
        }
        
        return snapshot.count > 0 ? Set(snapshot) : nil
    }
    
}
