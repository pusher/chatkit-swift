import Foundation

public struct PCBasicMultipartMessage: PCCommonBasicMessage {
    public let id: Int
    public let senderID: String
    public let roomID: String
    let parts: [PCPart]
    let createdAt: String
    let updatedAt: String
}
