
struct RoomListState: ListState {
    
    // MARK: - Types
    
    typealias StateElement = RoomState
    
    // MARK: - Properties
    
    let elements: [String : RoomState]
    
    let iteratorIndexes: [String]
    var iteratorIndex: Int?
    
    static let empty: RoomListState = RoomListState(elements: [])
    
    // MARK: - Accessors
    
    let isComplete = true
    
    // MARK: - Initializers
    
    init(elements: [String : RoomState]) {
        self.elements = elements
        
        self.iteratorIndex = nil
        self.iteratorIndexes = Array(elements.keys)
    }
    
    init(elements: [RoomState]) {
        let elements = elements.reduce(into: [String : RoomState]()) { $0[$1.identifier] = $1 }
        
        self.init(elements: elements)
    }
    
    // MARK: - Supplementation
    
    func supplement(withState supplementalState: RoomListState) -> RoomListState {
        let rooms = self.elements.mapValues { (room) -> RoomState in
            if let supplementalRoom = supplementalState[room.identifier] {
                return room.supplement(withState: supplementalRoom)
            }
            
            return room
        }
        
        return RoomListState(elements: rooms)
    }
    
}

// MARK: - Equatable

extension RoomListState: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.elements == rhs.elements
    }
    
}

// MARK: - Hashable

extension RoomListState: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.elements)
    }
    
}
