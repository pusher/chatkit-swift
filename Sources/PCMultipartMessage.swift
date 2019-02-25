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
    let type: String
    let payload: PCMultipartPayload
}

public struct PCMultipartInlinePayload {
    let content: String
}

public struct PCMultipartURLPayload {
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
            return payload1.content == payload2.content
        case (let .url(payload1), let .url(payload2)):
            return payload1.url == payload2.url
        case (let .attachment(payload1), let .attachment(payload2)):
            return payload1.downloadUrl == payload2.downloadUrl && payload1.expiration == payload2.expiration && payload1.id == payload2.id && payload1.name == payload2.name && payload1.refreshUrl == payload2.refreshUrl && payload1.size == payload2.size
        default:
            return false
        }
    }
}

public class PCMultipartAttachmentPayload {
    let id: String
    let name: String?
    let customData: [String: Any]?
    let size: Int
    private let urlRefresher: PCMultipartAttachmentUrlRefresher
    internal let refreshUrl: String
    internal var downloadUrl: String
    internal var expiration: String

    init(
        id: String,
        name: String?,
        customData: [String: Any]?,
        size: Int,
        urlRefresher: PCMultipartAttachmentUrlRefresher,
        refreshUrl: String,
        downloadUrl: String,
        expiration: String
    ) {
        self.id = id
        self.name = name
        self.customData = customData
        self.size = size
        self.urlRefresher = urlRefresher
        self.refreshUrl = refreshUrl
        self.downloadUrl = downloadUrl
        self.expiration = expiration
    }

    func url() -> String {
        if (Date() > self.urlExpiry()) {
            self.urlRefresher.refresh(attachment: self) { newAttachment, error in
                guard error == nil else {
                    return
                }

                if newAttachment != nil {
                    self.downloadUrl = newAttachment!.downloadUrl
                    self.expiration = newAttachment!.expiration
                }
            }
        }

        return downloadUrl
    }

    func urlExpiry() -> Date {
        return PCDateFormatter.shared.formatString(self.expiration)
    }
}

public class PCMultipartAttachmentUrlRefresher {
    let client: Instance

    init(client: Instance) {
        self.client = client
    }

    func refresh(
        attachment: PCMultipartAttachmentPayload,
        completionHandler: @escaping (PCMultipartAttachmentPayload?, Error?) -> Void
    ) {
        let request = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: attachment.refreshUrl)
        self.client.request(
            using: request,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    self.client.logger.log("Failed to serialse attachment refresh attachment response", logLevel: .error)
                    return
                }

                guard let attachmentPayload = jsonObject as? [String: Any] else {
                    self.client.logger.log("Failed to assert refresh attachment response as a map", logLevel: .error)
                    return
                }

                guard let newAttachment = try? PCPayloadDeserializer.createMultipartAttachmentFromPayload(attachmentPayload, urlRefresher: self) else {
                    self.client.logger.log("Failed to deserialise attachment payload into attachment class", logLevel: .error)
                    return
                }

                completionHandler(newAttachment, nil)
                return
            },
            onError: { error in
                completionHandler(nil, error)
                return
            }
        )
    }
}
