
import Foundation

public struct PCPartRequest {
    let payload: PCPartRequestType

    public init(_ payload: PCPartRequestType) {
        self.payload = payload
    }
}

public struct PCPartInlineRequest {
    let type: String
    let content: String

    public init(type: String = "text/plain", content: String) {
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

    public init(type: String, url: String) {
        self.type = type
        self.url = url
    }

    func toMap() -> [String: Any] {
        return [
            "type": self.type,
            "url": self.url,
        ]
    }
}

public struct PCPartAttachmentRequest {
    let type: String
    let file: Data
    let name: String?
    let customData: [String: Any]?

    public init(
        type: String,
        file: Data,
        name: String? = nil,
        customData: [String: Any]? = nil
    ) {
        self.type = type
        self.file = file
        self.name = name
        self.customData = customData
    }
}

public enum PCPartRequestType {
    case inline(_ payload: PCPartInlineRequest)
    case url(_ payload: PCPartUrlRequest)
    case attachment(_ payload: PCPartAttachmentRequest)
}

public struct PCMultipartAttachmentUploadRequest {
    let contentType: String
    let contentLength: Int
    let name: String?
    let customData: [String: Any]?

    func toMap() -> [String: Any] {
        var params: [String: Any] = [
            "content_type": contentType,
            "content_length": contentLength,
        ]

        if name != nil {
            params["name"] = name!
        }

        if customData != nil {
            params["custom_data"] = customData!
        }

        return params
    }
}

struct PCMultipartAttachmentUploadResponse {
    let attachmentID: String
    let uploadUrl: String
}
