import Foundation
import PusherPlatform

public struct MessageProvider {
    
    // MARK: - Properties
    
    private let store: Store<MessageEntity>
    
    // MARK: - Accessors
    
    public var messages: [Message]? {
        return self.store.objects()
    }
    
    public var messagesWithText: [Message]? {
        let predicate = NSPredicate(format: "%@ IN %K", InlinePartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public var messagesWithURL: [Message]? {
        let predicate = NSPredicate(format: "%@ IN %K", URLPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public var messagesWithAttachment: [Message]? {
        let predicate = NSPredicate(format: "%@ IN %K", AttachmentPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public var lastMessage: Message? {
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: false)
        return self.store.object(orderedBy: [sortDescriptor])
    }
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.store = Store(persistenceController: persistenceController)
    }
    
    // MARK: - Public methods
    
    public func message(with identifier: String) -> Message? {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(MessageEntity.identifier), identifier)
        return self.store.object(for: predicate)
    }
    
    public func messages(of user: User) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.sender), user.objectID)
        return self.store.objects(for: predicate)
    }
    
    public func messages(in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.room), room.objectID)
        return self.store.objects(for: predicate)
    }
    
    public func messages(of user: User, in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(MessageEntity.sender), user.objectID, #keyPath(MessageEntity.room), room.objectID)
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithText(of user: User) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %@ IN %K", #keyPath(MessageEntity.sender), user.objectID, InlinePartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithText(in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %@ IN %K", #keyPath(MessageEntity.room), room.objectID, InlinePartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithText(of user: User, in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@ AND %@ IN %K", #keyPath(MessageEntity.sender), user.objectID, #keyPath(MessageEntity.room), room.objectID, InlinePartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithURL(of user: User) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %@ IN %K", #keyPath(MessageEntity.sender), user.objectID, URLPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithURL(in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %@ IN %K", #keyPath(MessageEntity.room), room.objectID, URLPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithURL(of user: User, in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@ AND %@ IN %K", #keyPath(MessageEntity.sender), user.objectID, #keyPath(MessageEntity.room), room.objectID, URLPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithAttachment(of user: User) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %@ IN %K", #keyPath(MessageEntity.sender), user.objectID, AttachmentPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithAttachment(in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %@ IN %K", #keyPath(MessageEntity.room), room.objectID, AttachmentPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func messagesWithAttachment(of user: User, in room: Room) -> [Message]? {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@ AND %@ IN %K", #keyPath(MessageEntity.sender), user.objectID, #keyPath(MessageEntity.room), room.objectID, AttachmentPartEntity.entity(), #keyPath(MessageEntity.parts.entity))
        return self.store.objects(for: predicate)
    }
    
    public func lastMessage(of user: User) -> Message? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.sender), user.objectID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: false)
        return self.store.object(for: predicate, orderedBy: [sortDescriptor])
    }
    
    public func lastMessage(in room: Room) -> Message? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(MessageEntity.room), room.objectID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: false)
        return self.store.object(for: predicate, orderedBy: [sortDescriptor])
    }
    
    public func lastMessage(of user: User, in room: Room) -> Message? {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(MessageEntity.sender), user.objectID, #keyPath(MessageEntity.room), room.objectID)
        let sortDescriptor = NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: false)
        return self.store.object(for: predicate, orderedBy: [sortDescriptor])
    }
    
}
