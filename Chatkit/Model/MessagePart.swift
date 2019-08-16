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

// MARK: - Model

extension MessagePart: Model {
}
