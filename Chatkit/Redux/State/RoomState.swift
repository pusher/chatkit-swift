import Foundation

struct RoomState: State {
    
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

extension RoomState: Equatable {}

// MARK: - Types

extension Array: State where Element == RoomState {}
