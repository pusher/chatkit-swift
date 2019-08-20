import Foundation
import CoreData
import PusherPlatform

class Store<T: NSManagedObject & Snapshotable & Identifiable> where T.Snapshot: Identifiable {
    
    // MARK: - Properties
    
    let persistenceController: PersistenceController
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    // MARK: - Internal methods
    
//    func object(with identifier: String) -> T.Snapshot? {
//        let predicate = NSPredicate(format: "%K = %@", "identifier", identifier)
//        return self.object(for: predicate)
//    }
    
    func object(for predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil) -> T.Snapshot? {
        var object: T? = nil
        let context = self.persistenceController.mainContext
        
        context.performAndWait {
            object = context.fetch(T.self, sortDescriptors: sortDescriptors, predicate: predicate)
        }
        
        if let object = object {
            return try? object.snapshot()
        }
        else {
            return nil
        }
    }
    
    func objects(for predicate: NSPredicate? = nil, orderedBy sortDescriptors: [NSSortDescriptor]? = nil) -> [T.Snapshot]? {
        var objects: [T]? = nil
        let context = self.persistenceController.mainContext
        
        context.performAndWait {
            objects = context.fetchAll(T.self, sortDescriptors: sortDescriptors, predicate: predicate)
        }
        
        if let objects = objects {
            return objects.compactMap { try? $0.snapshot() }
        }
        else {
            return nil
        }
    }
    
}
