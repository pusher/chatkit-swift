

enum MasterAction: Action {
    
    case addedToRoomAction(AddedToRoomAction)
    case initialStateAction(InitialStateAction)
    case readStateUpdatedAction(ReadStateUpdatedAction)
    case removedFromRoomAction(RemovedFromRoomAction)
    case roomDeletedAction(RoomDeletedAction)
    case roomUpdatedAction(RoomUpdatedAction)
    
}
