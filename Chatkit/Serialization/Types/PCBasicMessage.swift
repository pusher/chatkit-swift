import Foundation

public protocol PCCommonBasicMessage {
    var id: Int { get }
    var senderID: String {  get }
    var roomID: String { get }
}

public protocol PCEnrichedMessage {
    var id: Int { get }
    var sender: PCUser { get }
    var room: PCRoom { get }
}

public struct PCBasicMessage: PCCommonBasicMessage {
    public let id: Int
    public let senderID: String
    public let roomID: String
    let text: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let attachment: PCAttachment?
}
