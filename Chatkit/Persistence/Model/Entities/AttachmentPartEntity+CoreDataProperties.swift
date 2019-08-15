import Foundation
import CoreData

extension AttachmentPartEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<AttachmentPartEntity> {
        return NSFetchRequest<AttachmentPartEntity>(entityName: String(describing: AttachmentPartEntity.self))
    }
    
    @NSManaged var downloadURL: String
    @NSManaged var expiration: Date
    @NSManaged var identifier: String
    @NSManaged var metadata: Data?
    @NSManaged var name: String?
    @NSManaged var refreshURL: String
    @NSManaged var size: Int64
    
}
