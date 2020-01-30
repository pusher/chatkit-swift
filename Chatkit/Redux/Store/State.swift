
enum Internal {}

extension Internal {
    struct Room {
        let identifier: String
        let name: String
    }
}

extension Internal.Room: Equatable {}

extension Internal {
    struct User {
        let identifier: String
        let name: String
    }
}

extension Internal.User: Equatable {}

struct State {
    let currentUser: Internal.User?
    let joinedRooms: [Internal.Room]
    
    static let empty: State = State(currentUser: nil, joinedRooms: [])
}

extension State: Equatable {}
