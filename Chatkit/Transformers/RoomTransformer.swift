
struct RoomTransformer: Transformer {
    
    // MARK: - Types
    
    typealias InputState = RoomState
    typealias OutputModel = Room
    
    // MARK: - Mapping
    
    func transform(state: RoomState) -> Room {
        return Room(identifier: state.identifier,
                    name: state.name,
                    isPrivate: state.isPrivate,
                    unreadCount: state.readSummary.unreadCount,
                    lastMessageAt: state.lastMessageAt,
                    customData: state.customData,
                    createdAt: state.createdAt,
                    updatedAt: state.updatedAt)
    }
    
}
