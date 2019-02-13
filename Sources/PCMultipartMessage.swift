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

public class PCMultipartAttachmentPayload {
    let type: String
    let size: Int
    let name: String?
    let customData: [String: Any]?
    internal let refreshURL: String
    internal var downloadURL: String
    internal var expiration: String
    
     init(
        type: String,
        size: Int,
        name: String?,
        customData: [String: Any]?,
        refreshURL: String,
        downloadURL: String,
        expiration: String
    ) {
        self.type = type
        self.size = size
        self.name = name
        self.customData = customData
        self.refreshURL = refreshURL
        self.downloadURL = downloadURL
        self.expiration = expiration
    }
}

public enum PCMultipartPayload {
    case inlinePayload(payload: PCMultipartInlinePayload)
    case urlPayload(payload: PCMultipartURLPayload)
    case attachmentPayload(payload: PCMultipartAttachmentPayload)
}

struct PCMultipartAttachment {
    let id: String
    let downloadUrl: String
    let refreshUrl: String
    let expiration: String
    let name: String?
    let customData: [String: Any]?
    let size: Int
    
}
