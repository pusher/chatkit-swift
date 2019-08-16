import Foundation

public enum MessagePart {
    
    case text(MIMEType, String)
    case link(MIMEType, URL)
    case attachment(MIMEType, Identifier, DownloadURL, RefreshURL, Size, Expiration, Name?, Metadata?)
    
}

// MARK: - Types

public extension MessagePart {
    
    typealias MIMEType = String
    typealias Identifier = String
    typealias DownloadURL = URL
    typealias RefreshURL = URL
    typealias Size = Int64
    typealias Expiration = Date
    typealias Name = String
    
}

// MARK: - Hashable

extension MessagePart: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .text(mimeType, content):
            hasher.combine(mimeType)
            hasher.combine(content)
            
        case let .link(mimeType, url):
            hasher.combine(mimeType)
            hasher.combine(url)
            
        case let .attachment(mimeType, identifier, downloadURL, refreshURL, size, expiration, name, _):
            // Metadata is intentionally excluded from this calculation.
            hasher.combine(mimeType)
            hasher.combine(identifier)
            hasher.combine(downloadURL)
            hasher.combine(refreshURL)
            hasher.combine(size)
            hasher.combine(expiration)
            hasher.combine(name)
        }
    }

}

// MARK: - Equatable

extension MessagePart: Equatable {
    
    public static func == (lhs: MessagePart, rhs: MessagePart) -> Bool {
        switch (lhs, rhs) {
        case (let .text(lhsMIMEType, lhsContent),
              let .text(rhsMIMEType, rhsContent)):
            return lhsMIMEType == rhsMIMEType && lhsContent == rhsContent
            
        case (let .link(lhsMIMEType, lhsURL),
              let .link(rhsMIMEType, rhsURL)):
            return lhsMIMEType == rhsMIMEType && lhsURL == rhsURL
            
        case (let .attachment(lhsMIMEType, lhsIdentifier, lhsDownloadURL, lhsRefreshURL, lhsSize, lhsExpiration, lhsName, _),
              let .attachment(rhsMIMEType, rhsIdentifier, rhsDownloadURL, rhsRefreshURL, rhsSize, rhsExpiration, rhsName, _)):
            // Metadata is intentionally excluded from this comparison.
            return lhsMIMEType == rhsMIMEType && lhsIdentifier == rhsIdentifier && lhsDownloadURL == rhsDownloadURL && lhsRefreshURL == rhsRefreshURL && lhsSize == rhsSize && lhsExpiration == rhsExpiration && lhsName == rhsName
            
        default:
            return false
        }
    }
    
}

// MARK: - Model

extension MessagePart: Model {
}
