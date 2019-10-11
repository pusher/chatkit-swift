import Foundation

public enum RealTimeCollectionState {
    
    case initializing
    case online
    case degraded
    
}

public enum PagedCollectionState {
    
    case initializing
    case partiallyPopulated
    case fullyPopulated
    case fetching
    
}
