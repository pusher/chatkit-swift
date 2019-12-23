import Foundation
import CoreData
import PusherPlatform

struct ChatEventParser: EventParser {
    
    // MARK: - Properties
    
    let persistenceController: PersistenceController
    let logger: PPLogger?
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController, logger: PPLogger? = nil) {
        self.persistenceController = persistenceController
        self.logger = logger
    }
    
    // MARK: - Internal methods
    
    func parse(event: Event, from service: ServiceName, version: ServiceVersion, completionHandler: @escaping CompletionHandler) {
        guard service == .chat && version == .version6 else {
            self.logger?.log("Received event from an unsupported service.", logLevel: .warning)
            completionHandler(NetworkingError.invalidEvent)
            return
        }
        
        switch event.name {
        case .initialState:
            parseInitialState(payload: event.payload, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Private methods
    
    private func parseInitialState(payload: [String : Any], completionHandler: @escaping CompletionHandler) {
        self.persistenceController.performBackgroundTask { backgroundContext in
            guard let roomsPayload = payload[Event.Key.rooms] as? [[String : Any]] else {
                return
            }
            
            for roomPayload in roomsPayload {
                if let _ = self.room(for: roomPayload, in: backgroundContext) {
                    // TODO: Attach relationships in future.
                }
            }
            
            self.persistenceController.save(includingBackgroundTaskContext: backgroundContext) { error in
                if let error = error {
                    self.logger?.log("Failed to save '\(Event.Name.initialState)' event with error: \(error.localizedDescription)", logLevel: .warning)
                }
                
                completionHandler(nil)
            }
        }
    }
    
    private func room(for payload: [String : Any], in context: NSManagedObjectContext) -> RoomEntity? {
        guard let identifier = payload[Event.Key.identifier] as? String,
            let name = payload[Event.Key.name] as? String,
            let isPrivate = payload[Event.Key.private] as? Bool,
            let unreadCount = payload[Event.Key.unreadCount] as? UInt32,
            let createdAtString = payload[Event.Key.createdAt] as? String,
            let createdAt = Date(fromISO8601String: createdAtString),
            let updatedAtString = payload[Event.Key.updatedAt] as? String,
            let updatedAt = Date(fromISO8601String: updatedAtString) else {
                return nil
        }
        
        let room = context.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), identifier) ?? context.create(RoomEntity.self)
        room.identifier = identifier
        room.name = name
        room.isPrivate = isPrivate
        room.unreadCount = Int64(unreadCount)
        room.createdAt = createdAt
        room.updatedAt = updatedAt
        
        if let customData = payload[Event.Key.customData] as? CustomData {
            room.customData = CustomDataSerializer.serialize(customData: customData)
        }
        else {
            room.customData = nil
        }
        
        if let deletedAtString = payload[Event.Key.deletedAt] as? String {
            room.deletedAt = Date(fromISO8601String: deletedAtString)
        }
        else {
            room.deletedAt = nil
        }
        
        return room
    }
    
}
