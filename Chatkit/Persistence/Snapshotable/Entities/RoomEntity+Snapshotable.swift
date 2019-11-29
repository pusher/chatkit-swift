import Foundation

extension RoomEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Room
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? {
        return [#keyPath(RoomEntity.members),
                #keyPath(RoomEntity.typingMembers),
                #keyPath(RoomEntity.lastMessage),
                #keyPath(RoomEntity.lastMessage.sender),
                #keyPath(RoomEntity.lastMessage.parts),
                #keyPath(RoomEntity.lastMessage.cursors),
                "\(#keyPath(RoomEntity.lastMessage.cursors)).\(#keyPath(CursorEntity.user))",           // Perhaps in future this could be replaced with #keyPath(RoomEntity.lastMessage.cursors.user)
                "\(#keyPath(RoomEntity.lastMessage.cursors)).\(#keyPath(CursorEntity.readMessages))"]   // Perhaps in future this could be replaced with #keyPath(RoomEntity.lastMessage.cursors.readMessages)
    }
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Room {
        let lastMessage = (try? self.lastMessage?.snapshot()) ?? nil
        let customData = CustomDataSerializer.deserialize(data: self.customData)
        
        return Room(identifier: self.identifier,
                    name: self.name,
                    isPrivate: self.isPrivate,
                    unreadCount: UInt64(self.unreadCount),
                    lastMessage: lastMessage,
                    customData: customData,
                    createdAt: self.createdAt,
                    updatedAt: self.updatedAt,
                    deletedAt: self.deletedAt,
                    objectID: self.objectID)
    }
    
    // MARK: - Private methods
    
    private func snapshot(_ members: NSOrderedSet?) -> [User] {
        guard let members = members?.array as? [UserEntity] else {
            return []
        }
        
        let snapshot = members.compactMap { try? $0.snapshot() }
        
        return snapshot.count > 0 ? snapshot : []
    }
    
}
