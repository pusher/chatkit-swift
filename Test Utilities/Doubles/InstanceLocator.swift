import XCTest
@testable import PusherChatkit

extension XCTest {
    // We might like to use a `DummyInstanceLocator` directly in a test so here we
    // provide a (faux) initialiser that sets `file` and `line` automatically
    // making the tests themeselves cleaner and more readable.
    // Typically we shouldn't do this on Dummy's though which is why we restrict to within XCTest only.
    public func DummyInstanceLocator(file: StaticString = #file, line: UInt = #line) -> DummyInstanceLocator {
        let dummy: DummyInstanceLocator = .init(file: file, line: line)
        return dummy
    }
}

public class DummyInstanceLocator: DummyBase, InstanceLocator {
    
    public var region: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    
    public var identifier: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
    
    public var version: String {
        DummyFail(sender: self, function: #function)
        return ""
    }
}

public class StubInstanceLocator: StubBase, InstanceLocator {
    
    private static let separator: Character = ":"
    
    private let region_toReturn: String?
    public private(set) var region_actualCallCount: UInt = 0
    
    private let identifier_toReturn: String?
    public private(set) var identifier_actualCallCount: UInt = 0
    
    private let version_toReturn: String?
    public private(set) var version_actualCallCount: UInt = 0
    
    public init(string instanceLocatorString: String,
                file: StaticString = #file, line: UInt = #line) {
        
        let components = instanceLocatorString.split(separator: Self.separator)
        let valid = components.count == 3
        
        self.region_toReturn = valid ? String(components[1]) : nil
        self.identifier_toReturn = valid ? String(components[2]) : nil
        self.version_toReturn = valid ? String(components[0]) : nil
        
        super.init(file: file, line: line)
    }
    public init(region_toReturn: String? = nil,
                identifier_toReturn: String? = nil,
                version_toReturn: String? = nil,
                file: StaticString = #file, line: UInt = #line) {
        
        self.region_toReturn = region_toReturn
        self.identifier_toReturn = identifier_toReturn
        self.version_toReturn = version_toReturn
        
        super.init(file: file, line: line)
    }
    
    // MARK: InstanceLocator
    
    public var region: String {
        region_actualCallCount += 1
        guard let region_toReturn = region_toReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return String()
        }
        return region_toReturn
    }
    
    public var identifier: String {
        identifier_actualCallCount += 1
        guard let identifier_toReturn = identifier_toReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return String()
        }
        return identifier_toReturn
    }
    
    public var version: String {
        version_actualCallCount += 1
        guard let version_toReturn = version_toReturn else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return String()
        }
        return version_toReturn
    }
}
