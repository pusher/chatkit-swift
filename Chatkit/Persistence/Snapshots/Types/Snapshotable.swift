import Foundation

protocol Snapshotable {
    
    // MARK: - Types
    
    associatedtype Snapshot: Model
    
    // MARK: - Methods
    
    func snapshot() -> Snapshot
    
}
