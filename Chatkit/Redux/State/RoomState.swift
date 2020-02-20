
struct RoomState: State {
    
    // MARK: - Properties
    
    let identifier: String
    let name: String
    let isPrivate: Bool
    let pushNotificationTitle: String?
    let customData: [String: AnyHashable]?
    let lastMessageAt: Date?
    let readSummary: ReadSummaryState
    let createdAt: Date
    let updatedAt: Date
    
    // MARK: - Accessors
    
    let isComplete = true
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: RoomState) -> RoomState {
        let readSummary = self.readSummary.supplement(withState: supplementalState.readSummary)
        
        return RoomState(identifier: self.identifier,
                         name: self.name,
                         isPrivate: self.isPrivate,
                         pushNotificationTitle: self.pushNotificationTitle,
                         customData: self.customData,
                         lastMessageAt: self.lastMessageAt,
                         readSummary: readSummary,
                         createdAt: self.createdAt,
                         updatedAt: self.updatedAt)
    }
    
}

// MARK: - Equatable

extension RoomState: Equatable {}
