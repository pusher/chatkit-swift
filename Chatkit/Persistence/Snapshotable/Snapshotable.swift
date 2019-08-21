import Foundation

protocol Snapshotable {
    
    // MARK: - Types
    
    associatedtype Snapshot: Model
    
    // MARK: - Properties
    
    static var prefetchedRelationships: [String]? { get }
    
    // MARK: - Methods
    
    func snapshot() throws -> Snapshot
    
}
