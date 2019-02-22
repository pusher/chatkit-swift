
import Foundation

public struct PCPartRequest {
    let payload: PCPartRequestType

    init(_ payload: PCPartRequestType) {
        self.payload = payload
    }
}

public struct PCPartInlineRequest {
    let type: String
    let content: String

    init(type: String = "text/plain", content: String) {
        self.type = type
        self.content = content
    }

    func toMap() -> [String: Any] {
        return [
            "type": self.type,
            "content": self.content,
        ]
    }
}

public struct PCPartUrlRequest {
    let type: String
    let url: String

    func toMap() -> [String: Any] {
        return [
            "type": self.type,
            "url": self.url,
        ]
    }
}

public struct PCPartAttachmentRequest {
    let type: String
    let attachmentID: String

    func toMap() -> [String: Any] {
        return [
            "type": self.type,
            "attachment": [
                "id": self.attachmentID,
            ]
        ]
    }
}

public enum PCPartRequestType {
    case inline(_ payload: PCPartInlineRequest)
    case url(_ payload: PCPartUrlRequest)
    case attachment(_ payload: PCPartAttachmentRequest)
}
