import Foundation

/// An enumeration representing the state of a data repository which serves real time data retrieved from
/// the Chatkit web service.
public enum RealTimeRepositoryState {
    
    /// The case representing an open connection to the Chatkit web service.
    case connected
    
    /// The case representing a problem with the connection to the Chatkit web service.
    case degraded
    
}

/// An enumeration representing the state of a data repository which serves paged data retrieved from
/// the Chatkit web service.
public enum PagedRepositoryState {
    
    /// The case representing a state in which the repository tries to retrieve data form the Chatkit web
    /// service.
    case fetching
    
    /// The case representing a state in which the repository is partially populated with data. More data
    /// is availabe to download from the Chatkit web service.
    case partiallyPopulated
    
    /// The case representing a state in which the repository is fully populated with data. No more data
    /// is availabe to download from the Chatkit web service.
    case fullyPopulated
    
}
