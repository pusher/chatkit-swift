import Foundation
import CoreData

extension URLPartEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<URLPartEntity> {
        return NSFetchRequest<URLPartEntity>(entityName: String(describing: URLPartEntity.self))
    }
    
    @NSManaged var url: String
    
}
