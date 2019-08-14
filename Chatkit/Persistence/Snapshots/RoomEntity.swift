import Foundation

extension RoomEntity: Snapshotable {
    
    // MARK: - Types
    
    typealias Snapshot = Room
    
    // MARK: - Methods
    
    func snapshot() -> Room {
        // TODO: Implement
        return Room()
    }
    
}
