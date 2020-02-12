
struct ReadState: State {
    
    // MARK: - Properties
    
    let identifier: String
    let name: String
    let isPrivate: Bool
    let pushNotificationTitle: String?
    let customData: [String: AnyHashable]?
    let lastMessageAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
}

// MARK: - Equatable

extension ReadState: Equatable {}
