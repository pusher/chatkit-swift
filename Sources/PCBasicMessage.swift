import Foundation

protocol PCCommonBasicMessage {
    var id: Int { get }
    var senderID: String {  get }
    var roomID: String { get }
    func enrichMessage(user: PCUser, room: PCRoom) -> PCEnrichedMessage
}

public protocol PCEnrichedMessage {
    var sender: PCUser { get }
    var room: PCRoom { get }
}

struct PCBasicMessage: PCCommonBasicMessage {
    let id: Int
    let senderID: String
    let roomID: String
    let text: String
    let createdAt: String
    let updatedAt: String
    let attachment: PCAttachment?
    
    func enrichMessage(user: PCUser, room: PCRoom) -> PCEnrichedMessage {
        return PCMessage(
            id: self.id,
            text: self.text,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            attachment: self.attachment,
            sender: user,
            room: room
        )
    }
}
