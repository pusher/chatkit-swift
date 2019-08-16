import Foundation

extension URLPartEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = MessagePart
    
    // MARK: - Internal methods
    
    func snapshot() throws -> MessagePart {
        guard let url = URL(string: self.url) else {
            throw SnapshotError.snapshotFailure
        }
        
        return MessagePart.link(self.type, url)
    }
    
}
