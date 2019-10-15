import Foundation

extension MessageEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Message
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? {
        return [#keyPath(MessageEntity.sender),
                #keyPath(MessageEntity.parts),
                #keyPath(MessageEntity.cursors),
                "\(#keyPath(MessageEntity.cursors)).\(#keyPath(CursorEntity.user))",            // Perhaps in future this could be replaced with #keyPath(MessageEntity.cursors.user)
                "\(#keyPath(MessageEntity.cursors)).\(#keyPath(CursorEntity.readMessages))"]    // Perhaps in future this could be replaced with #keyPath(MessageEntity.cursors.readMessages)
    }
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Message {
        let sender = try self.sender.snapshot()
        let parts = try snapshotParts()
        let readByUsers = snapshotReadByUsers()
        let lastReadByUsers = snapshotLastReadByUsers()
        
        return Message(identifier: self.identifier,
                       sender: sender,
                       parts: parts,
                       readByUsers: readByUsers,
                       lastReadByUsers: lastReadByUsers,
                       createdAt: self.createdAt,
                       updatedAt: self.updatedAt,
                       deletedAt: self.deletedAt,
                       objectID: self.objectID)
    }
    
    // MARK: - Private methods
    
    private func snapshotParts() throws -> [MessagePart] {
        let parts: [MessagePart] = self.parts.compactMap { part in
            if let part = part as? InlinePartEntity {
                return try? part.snapshot()
            }
            else if let part = part as? URLPartEntity {
                return try? part.snapshot()
            }
            else if let part = part as? AttachmentPartEntity {
                return try? part.snapshot()
            }
            else {
                return nil
            }
        }
        
        guard parts.count > 0 else {
            throw SnapshotError.snapshotFailure
        }
        
        return parts
    }
    
    private func snapshotReadByUsers() -> [User] {
        guard let cursors = self.cursors?.array as? [CursorEntity] else {
            return []
        }
        
        let users = cursors.compactMap { try? $0.user.snapshot() }
        return users.count > 0 ? users : []
    }
    
    private func snapshotLastReadByUsers() -> [User] {
        guard let cursors = self.cursors?.array as? [CursorEntity] else {
            return []
        }
        
        let users = cursors.compactMap { $0.readMessages.lastObject as? MessageEntity == self ? try? $0.user.snapshot() : nil }
        return users.count > 0 ? users : []
    }
    
}
