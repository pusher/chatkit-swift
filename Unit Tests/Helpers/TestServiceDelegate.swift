import Foundation
@testable import PusherChatkit

class TestServiceDelegate: ServiceDelegate {
    
    // MARK: - Types
    
    typealias Callback = (Event) -> Void
    
    // MARK: - Properties
    
    let callback: Callback?
    
    // MARK: - Initializers
    
    init(callback: Callback? = nil) {
        self.callback = callback
    }
    
    // MARK: - ServiceDelegate
    
    func service(_ service: Service, didReceiveEvent event: Event) {
        guard let callback = self.callback else {
            return
        }
        
        callback(event)
    }
    
}
