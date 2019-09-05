import Foundation
@testable import PusherChatkit

struct TestEventParser: EventParser {
    
    // MARK: - Types
    
    typealias Callback = (Event, ServiceName, ServiceVersion) -> Void
    
    // MARK: - Properties
    
    let name: String
    let shouldThrowError: Bool
    let callback: Callback?
    
    // MARK: - Initializers
    
    init(name: String, shouldThrowError: Bool = false, callback: Callback? = nil) {
        self.name = name
        self.shouldThrowError = shouldThrowError
        self.callback = callback
    }
    
    // MARK: - Internal methods
    
    func parse(event: Event, from service: ServiceName, version: ServiceVersion) throws {
        if shouldThrowError {
            throw NetworkingError.invalidEvent
        }
        
        guard let callback = callback else {
            return
        }
        
        callback(event, service, version)
    }
    
}
