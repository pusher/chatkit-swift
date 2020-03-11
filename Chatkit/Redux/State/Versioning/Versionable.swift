
protocol Versionable {
    
    // MARK: - Types
    
    typealias Version = UInt64
    
    // MARK: - Properties
    
    var version: Version { get }
    var signature: VersionSignature { get }
    
}
