import Foundation

protocol EventParser {
    
    // MARK: - Methods
    
    func parse(event: Event, from service: ServiceName, version: ServiceVersion) throws
    
}
