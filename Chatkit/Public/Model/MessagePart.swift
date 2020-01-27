import Foundation

/// An enumeration representing a message part retrieved from the Chatkit web service.
public enum MessagePart {
    
    /// A message part with inline content.
    case inline(MIMEType, String)
    
    /// A message part where content has been uploaded to a URL which is not managed by Chatkit.
    case link(MIMEType, URL)
    
    /// A message part where content has been uploaded to Chatkit managed attachment storage.
    case attachment(MIMEType, Identifier, DownloadURL, RefreshURL, Size, Expiration, Name?, CustomData?)
    
}

// MARK: - Types

public extension MessagePart {
    
    /// The MIME type of the content.
    typealias MIMEType = String
    
    /// The unique identifier of the attachment.
    typealias Identifier = String
    
    /// Download `URL` of the attachment.
    typealias DownloadURL = URL
    
    /// Refresh `URL` of the attachment.
    typealias RefreshURL = URL
    
    /// The size of the attachment in bytes.
    typealias Size = Int64
    
    /// Expiration `Date` of the attachment.
    typealias Expiration = Date
    
    /// The filename associated with the attachment.
    typealias Name = String
    
}

// MARK: - Hashable

extension MessagePart: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    ///
    /// - Parameters:
    ///     - hasher: The hasher to use when combining the components of this instance.
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .inline(mimeType, content):
            hasher.combine(mimeType)
            hasher.combine(content)
            
        case let .link(mimeType, url):
            hasher.combine(mimeType)
            hasher.combine(url)
            
        case let .attachment(mimeType, identifier, downloadURL, refreshURL, size, expiration, name, _):
            // User data is intentionally excluded from this calculation.
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
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b` implies that
    /// `a != b` is `false`.
    ///
    /// - Parameters:
    ///     - lhs: A value to compare.
    ///     - rhs: Another value to compare.
    public static func == (lhs: MessagePart, rhs: MessagePart) -> Bool {
        switch (lhs, rhs) {
        case (let .inline(lhsMIMEType, lhsContent),
              let .inline(rhsMIMEType, rhsContent)):
            return lhsMIMEType == rhsMIMEType
                && lhsContent == rhsContent
            
        case (let .link(lhsMIMEType, lhsURL),
              let .link(rhsMIMEType, rhsURL)):
            return lhsMIMEType == rhsMIMEType
                && lhsURL == rhsURL
            
        case (let .attachment(lhsMIMEType, lhsIdentifier, lhsDownloadURL, lhsRefreshURL, lhsSize, lhsExpiration, lhsName, _),
              let .attachment(rhsMIMEType, rhsIdentifier, rhsDownloadURL, rhsRefreshURL, rhsSize, rhsExpiration, rhsName, _)):
            // User data is intentionally excluded from this comparison.
            return lhsMIMEType == rhsMIMEType
                && lhsIdentifier == rhsIdentifier
                && lhsDownloadURL == rhsDownloadURL
                && lhsRefreshURL == rhsRefreshURL
                && lhsSize == rhsSize
                && lhsExpiration == rhsExpiration
                && lhsName == rhsName
            
        default:
            return false
        }
    }
    
}
