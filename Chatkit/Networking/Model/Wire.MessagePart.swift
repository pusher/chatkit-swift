import Foundation

extension Wire {
    
    internal enum MessageType {
        case content(String)
        case attachment(id: String)
        case url(URL)
    }
    
    internal struct MessagePart {
        
        let mimeType: String
        let type: MessageType
    }

}

extension Wire.MessagePart: Decodable {

    private struct Attachment: Decodable {
        let id: String
        
        private enum CodingKeys: String, CodingKey {
            case id
            
            var description: String {
                return "\"\(self.rawValue)\""
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case mimeType = "type"
        case content
        case attachment
        case url

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mimeType = try container.decode(String.self, forKey: .mimeType)
        
        let content = try container.decodeIfPresent(String.self, forKey: .content)
        let attachment = try container.decodeIfPresent(Attachment.self, forKey: .attachment)
        let url = try container.decodeIfPresent(URL.self, forKey: .url)

        switch (content, attachment, url) {
        
        case let (.some(content), .none, .none):
            type = .content(content)
        
        case let (.none, .some(attachment), .none):
            type = .attachment(id: attachment.id)
            
        case let (.none, .none, .some(url)):
            type = .url(url)
            
        default:
            let desc = "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."
            throw DecodingError.dataCorruptedError(forKey: .content, in: container, debugDescription: desc)
        }
    }
}

