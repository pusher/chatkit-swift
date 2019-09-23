import Foundation
import CoreData
import PusherPlatform

class FetchedResultsController<ResultType> : NSObject, NSFetchedResultsControllerDelegate where ResultType: NSManagedObject {
    
    // MARK: - Properties
    
    let sortDescriptors: [NSSortDescriptor]
    
    weak var delegate: FetchedResultsControllerDelegate?
    
    private let controller: NSFetchedResultsController<ResultType>
    
    private var insertedObjects: [Int] = []
    
    // MARK: - Accessors
    
    var context: NSManagedObjectContext {
        return self.controller.managedObjectContext
    }
    
    var predicate: NSPredicate? {
        return self.controller.fetchRequest.predicate
    }
    
    var fetchBatchSize: Int {
        return self.controller.fetchRequest.fetchBatchSize
    }
    
    var numberOfObjects: Int {
        return self.controller.fetchedObjects?.count ?? 0
    }
    
    // MARK: - Initializers
    
    init(sortDescriptors: [NSSortDescriptor], predicate: NSPredicate? = nil, fetchBatchSize: Int = 50, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<ResultType>(entityName: String(describing: ResultType.self))
        fetchRequest.fetchBatchSize = fetchBatchSize
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        self.sortDescriptors = sortDescriptors
        self.controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        self.controller.delegate = self
        
        do {
            try self.controller.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Internal methods
    
    func object(at index: Int) -> ResultType? {
        let indexPath = self.indexPath(for: index)
        return self.controller.object(at: indexPath)
    }
    
    func index(for object: ResultType) -> Int? {
        let indexPath = self.controller.indexPath(forObject: object)
        return indexPath?.item
    }
    
    // MARK: - Private methods
    
    private func indexPath(for index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
    
    private func commitInsertions() {
        // FIXME: Assumes that insertions are contiguous
        
        self.insertedObjects.sort { $0 < $1 }
        
        if let lower = self.insertedObjects.first, let upper = self.insertedObjects.last {
            let range = Range<Int>(uncheckedBounds: (lower: lower, upper: upper + 1))
            
            self.delegate?.fetchedResultsController(self, didInsertObjectsWithRange: range)
        }
        
        self.insertedObjects.removeAll()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let object = anObject as? ResultType else {
            return
        }
        
        switch type {
        case .insert:
            guard let index = newIndexPath?.item else {
                return
            }
            
            self.insertedObjects.append(index)
        
        case .update:
            guard let index = indexPath?.item else {
                return
            }
            
            self.delegate?.fetchedResultsController(self, didUpdateObject: object, at: index)
            
        case .move:
            // FIXME: Ignore for now.
            break
            
        case .delete:
            guard let index = indexPath?.item else {
                return
            }
            
            self.delegate?.fetchedResultsController(self, didDeleteObject: object, at: index)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.commitInsertions()
    }
    
}

// MARK: - Delegate

protocol FetchedResultsControllerDelegate: class {
    
    func fetchedResultsController<ResultType: NSManagedObject>(_ fetchedResultsController: FetchedResultsController<ResultType>, didInsertObjectsWithRange range: Range<Int>)
    func fetchedResultsController<ResultType: NSManagedObject>(_ fetchedResultsController: FetchedResultsController<ResultType>, didUpdateObject: ResultType, at index: Int)
    func fetchedResultsController<ResultType: NSManagedObject>(_ fetchedResultsController: FetchedResultsController<ResultType>, didDeleteObject: ResultType, at index: Int)
    
}
