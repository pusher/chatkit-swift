import Foundation

struct PCBasicMultipartMessage: PCCommonBasicMessage {
    let id: Int
    let senderID: String
    let roomID: String
    let parts: [PCPart]
    let createdAt: String
    let updatedAt: String
    
    func enrichMessage(user: PCUser, room: PCRoom) -> PCEnrichedMessage {
        return PCMultipartMessage(
            id: self.id,
            sender: user,
            room: room,
            parts: self.parts,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
