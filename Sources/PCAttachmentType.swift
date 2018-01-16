import Foundation

public enum PCAttachmentType {
    case fileData(_: Data, name: String)
    case fileURL(_: URL, name: String)
    case link(_: String, type: String)
}
