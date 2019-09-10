import XCTest
import Mockingjay
import PusherPlatform
@testable import PusherChatkit

// MARK: - Networking

internal extension XCTest {
    
    struct Networking {
        
        // MARK: - Properties
        
        static let testInstanceLocator = "test:instance:locator"
        
        // MARK: - Paths
        
        enum Path: String {
            
            case users
            
        }
        
    }
    
}

// MARK: - Mockingjay

internal extension XCTest {
    
    // MARK: - Properties
    
    private static let instanceLocatorSeparator: Character = ":"
    
    // MARK: - Internal methods
    
    @discardableResult func stubSubscription(of service: ServiceName, version: ServiceVersion, instanceLocator: String, path: Networking.Path, with jsonFilename: String) -> Mockingjay.Stub? {
        let bundle = Bundle(for: type(of: self))
        
        guard let uri = uri(of: service, version: version, instanceLocator: instanceLocator, path: path),
            let stubURL = bundle.url(forResource: jsonFilename, withExtension: "json"),
            let json = try? String(contentsOf: stubURL).replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: ""),
            let data = "[1, \"\", {}, \(json)]\n".data(using: .utf8) else {
                return nil
        }
        
        return stub(Mockingjay.uri(uri), jsonData(data))
    }
    
    @discardableResult func stubSubscription(of service: ServiceName, version: ServiceVersion, instanceLocator: String, path: Networking.Path, with status: Int) -> Mockingjay.Stub? {
        guard let uri = uri(of: service, version: version, instanceLocator: instanceLocator, path: path) else {
            return nil
        }
        
        return stub(Mockingjay.uri(uri), http(status))
    }
    
    // MARK: - Private methods
    
    private func uri(of service: ServiceName, version: ServiceVersion, instanceLocator: String, path: Networking.Path) -> String? {
        let instanceLocatorComponents = instanceLocator.split(separator: XCTest.instanceLocatorSeparator)
        
        guard instanceLocatorComponents.count == 3,
            let identifier = instanceLocatorComponents.last,
            let host = try? PPBaseClient.host(for: instanceLocator) else {
                return nil
        }
        
        return "https://\(host)/services/\(service.rawValue)/\(version.rawValue)/\(identifier)/\(path)"
    }
    
}
