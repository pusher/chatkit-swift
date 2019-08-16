import Foundation

extension MessageEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Message
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Message {
        // TODO: Implement
        return Message()
    }
    
}
