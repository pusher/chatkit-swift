import Foundation
@testable import PusherChatkit

struct TestEventParser: EventParser {
    
    // MARK: - Types
    
    typealias Callback = (Event, ServiceName, ServiceVersion) -> Void
    
    // MARK: - Properties
    
    let name: String
    let shouldReturnError: Bool
    let callback: Callback?
    
    // MARK: - Initializers
    
    init(name: String, shouldReturnError: Bool = false, callback: Callback? = nil) {
        self.name = name
        self.shouldReturnError = shouldReturnError
        self.callback = callback
    }
    
    // MARK: - Internal methods
    
    func parse(event: Event, from service: ServiceName, version: ServiceVersion, completionHandler: @escaping CompletionHandler) {
        if self.shouldReturnError {
            completionHandler(NetworkingError.invalidEvent)
        }
        else {
            if let callback = self.callback {
                callback(event, service, version)
            }
            
            completionHandler(nil)
        }
    }
    
}
