import Foundation
import PusherPlatform

public final class PCMultipartMessage {
    public let id: Int
    public let sender: PCUser
    public let room:PCRoom
    public let parts: [PCPart]
    public let createdAt: String
    public let updatedAt: String
    
    public var createdAtDate: Date { return PCDateFormatter.shared.formatString(self.createdAt) }
    public var updatedAtDate: Date { return PCDateFormatter.shared.formatString(self.updatedAt) }
    
    public init(
        id: Int,
        sender: PCUser,
        room: PCRoom,
        parts: [PCPart],
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.sender = sender
        self.room = room
        self.parts = parts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension PCMultipartMessage: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Message - ID: \(self.id), sender: \(self.sender.id)"
    }
}

extension PCMultipartMessage: Hashable {
    public var hashValue: Int {
        return self.id
    }
    
    public static func ==(lhs: PCMultipartMessage, rhs: PCMultipartMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

public struct PCPart {
    let payload: PCMultipartPayload
}

public struct PCMultipartInlinePayload {
    let type: String
    let content: String
}

public struct PCMultipartURLPayload {
    let type: String
    let url: String
}

public enum PCMultipartPayload { 
    case inlinePayload(payload: PCMultipartInlinePayload)
    case urlPayload(payload: PCMultipartURLPayload)
    case attachmentPayload(payload: PCMultipartAttachmentPayload)
}

public struct PCMultipartAttachmentPayload {
    let id: String
    let downloadUrl: String
    let refreshUrl: String
    let expiration: String
    let name: String?
    let customData: [String: Any]?
    let size: Int
}
