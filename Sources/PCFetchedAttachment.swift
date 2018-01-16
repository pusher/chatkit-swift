import Foundation

public struct PCFetchedAttachmentFile {
    public let bytes: Int
    public let lastModified: Int
    public let name: String
}

public struct PCFetchedAttachment {
    public let file: PCFetchedAttachmentFile
    public let link: String
    public let ttl: Int
}
