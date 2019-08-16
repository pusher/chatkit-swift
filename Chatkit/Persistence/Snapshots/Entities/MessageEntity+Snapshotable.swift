import Foundation

extension MessageEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Message
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Message {
        let sender = try self.sender.snapshot()
        let parts = try snapshotParts()
        
        return Message(identifier: self.identifier, sender: sender, parts: parts, createdAt: self.createdAt, updatedAt: self.updatedAt, deletedAt: self.deletedAt)
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
    
}
