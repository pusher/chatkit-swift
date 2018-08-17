import Foundation

public final class PCSynchronizedDictionary<KeyType:Hashable, ValueType>: ExpressibleByDictionaryLiteral, Collection, Sequence {
    public typealias Key = KeyType
    public typealias Value = ValueType

    public typealias Index = Dictionary<KeyType, ValueType>.Index
    public typealias Element = Dictionary<KeyType, ValueType>.Element

    public var startIndex: Index { return underlyingDictionary.startIndex }
    public var endIndex: Index { return underlyingDictionary.endIndex }

    public subscript(position: Index) -> (key: KeyType, value: ValueType) {
        get {
            return underlyingDictionary[position]
        }
    }

    public func index(after i: Index) -> Index {
        return underlyingDictionary.index(after: i)
    }

    internal var underlyingDictionary: [KeyType: ValueType]
    private let queue = DispatchQueue(
        label: "synchronized.dictionary.access.\(UUID().uuidString)",
        attributes: .concurrent
    )

    public init(dictionary: [KeyType: ValueType]) {
        self.underlyingDictionary = dictionary
    }

    public convenience init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        var dict = [KeyType: ValueType]()
        for (key, value) in elements {
            dict[key] = value
        }
        self.init(dictionary: dict)
    }

    subscript(key: KeyType) -> ValueType? {
        get {
            var value: ValueType?
            queue.sync(flags: .barrier) { value = self.underlyingDictionary[key] }
            return value
        }

        set {
            queue.async {
                self.underlyingDictionary[key] = newValue
            }
        }
    }

    func removeValue(forKey key: KeyType) -> ValueType? {
        var oldValue: ValueType? = nil
        queue.sync(flags: .barrier) {
            oldValue = self.underlyingDictionary.removeValue(forKey: key)
        }
        return oldValue
    }

    func removeAll() {
        queue.sync(flags: .barrier) {
            self.underlyingDictionary.removeAll()
        }
    }
}
