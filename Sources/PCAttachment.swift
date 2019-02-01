import Foundation
import PusherPlatform

public struct PCAttachment {
    public let link: String
    public let type: String
    public let name: String

    public init(link: String, type: String, name: String) {
        self.link = link
        self.type = type
        self.name = name
    }
}
