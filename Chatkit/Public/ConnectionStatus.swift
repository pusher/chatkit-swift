import Foundation

/// An enumeration representing the status of the networking connection to the Chatkit web service.
public enum ConnectionStatus {
    
    /// The case representing an open connection to the Chatkit web service.
    case connected
    
    /// The case representing a state in which the SDK tries to establish a connection to the Chatkit web
    /// service.
    case connecting
    
    /// The case representing a closed connection to the Chatkit web service.
    case disconnected
    
}
