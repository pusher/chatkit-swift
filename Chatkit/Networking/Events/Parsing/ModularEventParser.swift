import Foundation
import CoreData
import PusherPlatform

class ModularEventParser: EventParser {
    
    // MARK: - Properties
    
    private var parsers: [ServiceIdentifier : EventParser]
    
    let logger: PPLogger?
    
    // MARK: - Accessors
    
    var numberOfRegistrations: Int {
        return self.parsers.count
    }
    
    // MARK: - Initializers
    
    init(logger: PPLogger? = nil) {
        self.parsers = [ServiceIdentifier : EventParser]()
        self.logger = logger
    }
    
    // MARK: - Internal methods
    
    func register(parser: EventParser, for service: ServiceName, with version: ServiceVersion) {
        let identifier = ServiceIdentifier(name: service, version: version)
        self.parsers[identifier] = parser
    }
    
    func unregisterParser(for service: ServiceName, with version: ServiceVersion) {
        let identifier = ServiceIdentifier(name: service, version: version)
        self.parsers.removeValue(forKey: identifier)
    }
    
    func parser(for service: ServiceName, with version: ServiceVersion) -> EventParser? {
        let identifier = ServiceIdentifier(name: service, version: version)
        return self.parsers[identifier]
    }
    
    func parse(event: Event, from service: ServiceName, version: ServiceVersion) throws {
        guard let parser = parser(for: service, with: version) else {
            self.logger?.log("Unsupported event with name: '\(event.name)' from service: '\(service)' with version: '\(version)'", logLevel: .warning)
            return
        }
        
        try parser.parse(event: event, from: service, version: version)
    }
    
}

// MARK: - Service identifier

private extension ModularEventParser {
    
    struct ServiceIdentifier: Hashable {
        
        // MARK: - Properties
        
        let name: ServiceName
        let version: ServiceVersion
        
    }
    
}
