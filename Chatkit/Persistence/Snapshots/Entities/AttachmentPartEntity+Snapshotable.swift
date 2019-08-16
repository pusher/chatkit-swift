import Foundation

extension AttachmentPartEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = MessagePart
    
    // MARK: - Internal methods
    
    func snapshot() throws -> MessagePart {
        guard let downloadURL = URL(string: self.downloadURL), let refreshURL = URL(string: self.refreshURL) else {
            throw SnapshotError.snapshotFailure
        }
        
        let metadata = (try? MetadataParser.deserialize(data: self.metadata)) ?? nil
        
        return MessagePart.attachment(self.type, self.identifier, downloadURL, refreshURL, self.size, self.expiration, self.name, metadata)
    }
    
}
