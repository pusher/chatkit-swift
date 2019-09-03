import Foundation
import CoreData
import PusherPlatform

struct PersistenceEventParser: EventParser {
    
    // MARK: - Properties
    
    let persistenceController: PersistenceController
    let logger: PPLogger
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController, logger: PPLogger) {
        self.persistenceController = persistenceController
        self.logger = logger
    }
    
    // MARK: - Internal methods
    
    func parse(event: Event) {
        switch event.name {
        case .initialState:
            parseInitialState(payload: event.payload)
        }
        
        self.persistenceController.save()
    }
    
    // MARK: - Private methods
    
    private func parseInitialState(payload: [String : Any]) {
        self.persistenceController.performBackgroundTask { backgroundContext in
            guard let roomsPayload = payload["rooms"] as? [[String: Any]] else {
                return
            }
            
            for roomPayload in roomsPayload {
                if let _ = try? self.room(for: roomPayload, in: backgroundContext) {
                    // TODO: Attach relationships in future.
                }
            }
            
            do {
                try backgroundContext.save()
            } catch {
                self.logger.log("Failed to save '\(Event.Name.initialState)' event with error: \(error.localizedDescription)", logLevel: .warning)
            }
        }
    }
    
    private func room(for payload: [String : Any], in context: NSManagedObjectContext) throws -> RoomEntity? {
        guard let identifier = payload[Event.Key.identifier] as? String,
            let name = payload[Event.Key.name] as? String,
            let isPrivate = payload[Event.Key.private] as? Bool,
            let unreadCount = payload[Event.Key.unreadCount] as? Int64,
            let createdAtString = payload[Event.Key.createdAt] as? String,
            let createdAt = DateFormatter.default.date(from: createdAtString),
            let updatedAtString = payload[Event.Key.updatedAt] as? String,
            let updatedAt = DateFormatter.default.date(from: updatedAtString) else {
                throw NetworkingError.invalidEvent
        }
        
        let room = context.fetch(RoomEntity.self, filteredBy: "%K == %@", #keyPath(RoomEntity.identifier), identifier) ?? context.create(RoomEntity.self)
        room.identifier = identifier
        room.name = name
        room.isPrivate = isPrivate
        room.unreadCount = unreadCount
        room.createdAt = createdAt
        room.updatedAt = updatedAt
        
        if let metadata = payload[Event.Key.customData] as? Metadata {
            room.metadata = MetadataSerializer.serialize(metadata: metadata)
        }
        
        if let deletedAtString = payload[Event.Key.deletedAt] as? String {
            room.deletedAt = DateFormatter.default.date(from: deletedAtString)
        }
        
        return room
    }
    
}
