import Foundation

/// An enumeration representing the state of a data provider which serves real time data retrieved from
/// the Chatkit web service.
public enum RealTimeProviderState {
    
    /// The case representing an open connection to the Chatkit web service.
    case connected
    
    /// The case representing a problem with the connection to the Chatkit web service.
    case degraded
    
}

/// An enumeration representing the state of a data provider which serves paged data retrieved from
/// the Chatkit web service.
public enum PagedProviderState {
    
    /// The case representing a state in which the provider tries to retrieve data form the Chatkit web
    /// service.
    case fetching
    
    /// The case representing a state in which the provider is partially populated with data. More data
    /// is availabe to download from the Chatkit web service.
    case partiallyPopulated
    
    /// The case representing a state in which the provider is fully populated with data. No more data
    /// is availabe to download from the Chatkit web service.
    case fullyPopulated
    
}
