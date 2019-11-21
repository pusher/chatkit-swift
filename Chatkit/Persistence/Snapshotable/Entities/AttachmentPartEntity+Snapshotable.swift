import Foundation

extension AttachmentPartEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = MessagePart
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? {
        return nil
    }
    
    // MARK: - Internal methods
    
    func snapshot() throws -> MessagePart {
        guard let downloadURL = URL(string: self.downloadURL), let refreshURL = URL(string: self.refreshURL) else {
            throw SnapshotError.snapshotFailure
        }
        
        let customData =  CustomDataSerializer.deserialize(data: self.customData)
        
        return MessagePart.attachment(self.type, self.identifier, downloadURL, refreshURL, self.size, self.expiration, self.name, customData)
    }
    
}
