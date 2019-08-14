import Foundation

extension MessageEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Message
    
    // MARK: - Methods
    
    func snapshot() -> Message {
        // TODO: Implement
        return Message()
    }
    
}
