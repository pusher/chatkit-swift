import Foundation

extension RoomEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Room
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? {
        return [#keyPath(RoomEntity.creator),
                #keyPath(RoomEntity.members),
                #keyPath(RoomEntity.typingMembers),
                #keyPath(RoomEntity.lastMessage),
                #keyPath(RoomEntity.lastMessage.sender),
                #keyPath(RoomEntity.lastMessage.parts),
                #keyPath(RoomEntity.lastMessage.cursors),
                #keyPath(RoomEntity.lastMessage.cursors.user),
                #keyPath(RoomEntity.lastMessage.cursors.readMessages)]
    }
    
    // MARK: - Accessors
    
    @objc var lastMessage: MessageEntity? {
        return self.messages?.lastObject as? MessageEntity
    }
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Room {
        let creator = try self.creator?.snapshot()
        let lastMessage = (try? self.lastMessage?.snapshot()) ?? nil
        let members = snapshot(self.members)
        let typingMembers = snapshot(self.typingMembers)
        let metadata = MetadataSerializer.deserialize(data: self.metadata)
        
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
