import Foundation
import CoreData

extension InlinePartEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<InlinePartEntity> {
        return NSFetchRequest<InlinePartEntity>(entityName: String(describing: InlinePartEntity.self))
    }
    
    @NSManaged var content: String
    
}
