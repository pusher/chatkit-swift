
/// An enumeration representing possible errors related to the Chatkit service.
public enum ChatkitError: Error {
    
    /// The error case representing an issue actioning the request because Chatkit is disconnected.
    case disconnected
    
    /// The error case representing an issue actioning the request because Chatkit is in the process of connecting.
    case connecting
    
    /// The error case representing an issue with the format of the provided instance locator.
    case invalidInstanceLocator
    
    /// The error case representing an issue with the format of the event received from Chatkit web service.
    case invalidEvent

}

extension ChatkitError: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case .disconnected:
            return "The request cannot be actioned. Chatkit is disconnected."
        case .connecting:
            return "The request cannot be actioned. Chatkit is in the process of connecting."
        case .invalidInstanceLocator:
            return "An issue was encountered with the format of the provided instance locator."
        case .invalidEvent:
            return "An issue was encountered with the format of the event received from Chatkit web service."
        }
    }
    
}
