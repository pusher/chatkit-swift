import Foundation

extension RoomEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Room
    
    // MARK: - Internal methods
    
    func snapshot() throws -> Room {
        // TODO: Implement
        return Room()
    }
    
}
