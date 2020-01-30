
extension InstanceLocator {
    
    var string: String {
        return [version, region, identifier].joined(separator: ":")
    }
    
}
