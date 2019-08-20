import Foundation
import CoreData

protocol Identifiable {
    
    // MARK: - Properties
    
    var objectID: NSManagedObjectID { get }
    
}
