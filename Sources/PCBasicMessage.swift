import Foundation

struct PCBasicMessage {
    let id: Int
    let senderID: String
    let roomID: String
    let text: String
    let createdAt: String
    let updatedAt: String
    let attachment: PCAttachment?
}
