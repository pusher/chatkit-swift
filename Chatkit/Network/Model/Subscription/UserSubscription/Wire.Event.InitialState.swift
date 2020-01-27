import Foundation


extension Wire.Event {
    
    internal struct InitialState {
        let currentUser: Wire.User
        let rooms: [Wire.Room]
        let readStates: [Wire.ReadState]
        let memberships: [Wire.Membership]
    }
    
}

extension Wire.Event.InitialState: Equatable {}

extension Wire.Event.InitialState: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case currentUser = "current_user"
        case rooms
        case readStates = "read_states"
        case memberships

        var description: String {
            return "\"\(self.rawValue)\""
        }
    }
}
