// TODO: Maybe make a PCUser protocol, or something similar

public struct PCUser {
    public let id: Int
    public let createdAt: String
    public let updatedAt: String
    public let name: String?
    public let customId: String?
    public let customData: [String: Any]?
}

extension PCUser: Hashable {

    public var hashValue: Int {
        return self.id
    }

    public static func ==(_ lhs: PCUser, _ rhs: PCUser) -> Bool {
        return lhs.id == rhs.id
    }

}
