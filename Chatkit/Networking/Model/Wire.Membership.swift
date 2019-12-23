import Foundation

extension Wire {

    internal struct Membership: Decodable {
        
        let roomIdentifier: String
        let userIdentifiers: [String]
        
        private enum CodingKeys: String, CodingKey {
            case roomIdentifier = "room_id"
            case userIdentifiers = "user_ids"

            var description: String {
                return "\"\(self.rawValue)\""
            }
        }

    }

}

