import Foundation

extension MessageEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Message
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Message {
        let sender = try self.sender.snapshot()
        let parts = try snapshotParts()
        let readByUsers: Set<User>? = snapshotReadByUsers()
        let lastReadByUsers: Set<User>? = snapshotLastReadByUsers()
        
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
    
    private func snapshotParts() throws -> Set<MessagePart> {
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
        
        return Set(parts)
    }
    
    private func snapshotReadByUsers() -> Set<User>? {
        guard let cursors = self.cursors else {
            return nil
        }
        
        let users = cursors.compactMap { try? $0.user.snapshot() }
        return users.count > 0 ? Set(users) : nil
    }
    
    private func snapshotLastReadByUsers() -> Set<User>? {
        guard let cursors = self.cursors else {
            return nil
        }
        
        let users = cursors.compactMap { $0.readMessages.lastObject as? MessageEntity == self ? try? $0.user.snapshot() : nil }
        return users.count > 0 ? Set(users) : nil
    }
    
}
