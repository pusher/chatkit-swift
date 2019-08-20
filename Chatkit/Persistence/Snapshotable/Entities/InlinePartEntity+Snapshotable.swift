import Foundation

extension InlinePartEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = MessagePart
    
    // MARK: - Internal methods
    
    func snapshot() throws -> MessagePart {
        return MessagePart.text(self.type, self.content)
    }
    
}
