import Foundation

/// An enumeration representing a networking error related to Chatkit web service.
public enum NetworkingError: Error {
    
    /// The error case representing an issue with the format of the provided instance locator.
    case invalidInstanceLocator
    
    /// The error case representing an issue with the format of the event received from Chatkit web service.
    case invalidEvent
    
    /// The error case representing an issue with data not being available due to the lost connection to the Chatkit web service.
    case disconnected
    
}
