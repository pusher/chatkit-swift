
class NonJSONHashable: Hashable {
    static func == (lhs: NonJSONHashable, rhs: NonJSONHashable) -> Bool {
        return false
    }
    
    func hash(into hasher: inout Hasher) {}
    
    var description: String {
        return "NonJSONHashable"
    }
}
