import Foundation
import PusherPlatform

public final class PCMultipartMessage: PCEnrichedMessage {
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
        return "Message - ID: \(self.id), sender: \(self.sender.id), parts: \(self.parts)"
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

    init(_ payload: PCMultipartPayload) {
        self.payload = payload
    }
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
    case inline(_ payload: PCMultipartInlinePayload)
    case url(_ payload: PCMultipartURLPayload)
    case attachment(_ payload: PCMultipartAttachmentPayload)
}

extension PCMultipartPayload: Equatable {
    public static func == (lhs: PCMultipartPayload, rhs: PCMultipartPayload) -> Bool {
        switch (lhs, rhs) {
        case (let .inline(payload1), let .inline(payload2)):
            return payload1.content == payload2.content && payload1.type == payload2.type
        case (let .url(payload1), let .url(payload2)):
            return payload1.url == payload2.url && payload1.type == payload2.type
        case (let .attachment(payload1), let .attachment(payload2)):
            return payload1.downloadUrl == payload2.downloadUrl && payload1.expiration == payload2.expiration && payload1.id == payload2.id && payload1.name == payload2.name && payload1.refreshUrl == payload2.refreshUrl && payload1.size == payload2.size
        default:
            return false
        }
    }
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
