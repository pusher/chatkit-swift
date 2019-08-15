import Foundation
import CoreData

extension PartEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<PartEntity> {
        return NSFetchRequest<PartEntity>(entityName: String(describing: PartEntity.self))
    }
    
    @NSManaged var type: String
    @NSManaged var message: MessageEntity
    
}
