import Foundation

extension Wire {

    internal struct Membership {
        
        let roomIdentifier: String
        let userIdentifiers: Set<String>

    }

}

extension Wire.Membership: Equatable {}

extension Wire.Membership: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case roomIdentifier = "room_id"
        case userIdentifiers = "user_ids"

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
    
}
