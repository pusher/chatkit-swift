import Foundation
import CoreData
import PusherPlatform

struct Store<Entity: NSManagedObject & Snapshotable & Identifiable> where Entity.Snapshot: Identifiable {
    
    // MARK: - Properties
    
    let persistenceController: PersistenceController
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - Internal methods
    
    func object(for predicate: NSPredicate? = nil, orderedBy sortDescriptors: [NSSortDescriptor]? = nil) -> Entity.Snapshot? {
        var snapshot: Entity.Snapshot? = nil
        let context = self.persistenceController.mainContext
        
        context.performAndWait {
            if let object = context.fetch(Entity.self, withRelationships: Entity.prefetchedRelationships, sortedBy: sortDescriptors, filteredBy: predicate) {
                snapshot = try? object.snapshot()
            }
        }
        
        return snapshot
    }
    
    func objects(for predicate: NSPredicate? = nil, orderedBy sortDescriptors: [NSSortDescriptor]? = nil) -> [Entity.Snapshot]? {
        var snapshots: [Entity.Snapshot]? = nil
        let context = self.persistenceController.mainContext
        
        context.performAndWait {
            let objects = context.fetchAll(Entity.self, withRelationships: Entity.prefetchedRelationships, sortedBy: sortDescriptors, filteredBy: predicate)
            snapshots = objects.compactMap { try? $0.snapshot() }
        }
        
        guard let result = snapshots, result.count > 0 else {
            return nil
        }
        
        return result
    }
    
}
