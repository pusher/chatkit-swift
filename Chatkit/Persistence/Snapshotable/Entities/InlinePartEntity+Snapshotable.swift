import Foundation

extension InlinePartEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = MessagePart
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? {
        return nil
    }
    
    // MARK: - Internal methods
    
    func snapshot() throws -> MessagePart {
        return MessagePart.inline(self.type, self.content)
    }
    
}
