import Foundation
import PusherPlatform

public class MessageProvider {
    
    // MARK: - Properties
    
    private let store: Store<MessageEntity>
    
    // MARK: - Accessors
    
    public var messages: [Message]? {
        return self.store.objects()
    }
    
    public var messagesWithText: [Message]? {
        // TODO: Implement
        return nil
    }
    
    public var messagesWithURL: [Message]? {
        // TODO: Implement
        return nil
    }
    
    public var messagesWithAttachment: [Message]? {
        // TODO: Implement
        return nil
    }
    
    public var lastMessage: Message? {
        // TODO: Implement
        return nil
    }
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.store = Store(persistenceController: persistenceController)
    }
    
    // MARK: - Public methods
    
    public func message(with identifier: String) -> Message? {
        // TODO: Implement
        return nil
    }
    
    public func messages(of user: User) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messages(in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messages(of user: User, in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithText(of user: User) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithText(in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithText(of user: User, in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithURL(of user: User) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithURL(in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithURL(of user: User, in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithAttachment(of user: User) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithAttachment(in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func messagesWithAttachment(of user: User, in room: Room) -> [Message]? {
        // TODO: Implement
        return nil
    }
    
    public func lastMessage(of user: User) -> Message? {
        // TODO: Implement
        return nil
    }
    
    public func lastMessage(in room: Room) -> Message? {
        // TODO: Implement
        return nil
    }
    
    public func lastMessage(of user: User, in room: Room) -> Message? {
        // TODO: Implement
        return nil
    }
    
}
