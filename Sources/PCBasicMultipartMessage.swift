import Foundation

struct PCBasicMultipartMessage {
    let id: Int
    let senderID: String
    let roomID: String
    let parts: [PCPart]
    let createdAt: String
    let updatedAt: String
}
