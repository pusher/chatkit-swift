import Foundation

// PCSynchronizedDictionary is a thead-safe dictionary
// A serial DispatchQueue is used to control access to it
// Reads and writes are both synchronous
public final class PCSynchronizedDictionary<KeyType: Hashable, ValueType>: ExpressibleByDictionaryLiteral {
    typealias Index = Dictionary<KeyType, ValueType>.Index
    typealias Element = Dictionary<KeyType, ValueType>.Element

    private var underlyingDictionary: [KeyType: ValueType]
    private let queue = DispatchQueue(
        label: "synchronized.dictionary.access.\(UUID().uuidString)"
    )

    init(dictionary: [KeyType: ValueType]) {
        self.underlyingDictionary = dictionary
    }

    public convenience init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        var dict = [KeyType: ValueType]()
        for (key, value) in elements {
            dict[key] = value
        }
        self.init(dictionary: dict)
    }

    var startIndex: Index { return underlyingDictionary.startIndex }
    var endIndex: Index { return underlyingDictionary.endIndex }

    var keys: Dictionary<KeyType, ValueType>.Keys {
        get {
            return queue.sync {
                return underlyingDictionary.keys
            }
        }
    }

    var first: (key: KeyType, value: ValueType)? {
        return queue.sync {
            return underlyingDictionary.first
        }
    }

    subscript(position: Index) -> (key: KeyType, value: ValueType) {
        get {
            return queue.sync {
                return underlyingDictionary[position]
            }
        }
    }

    func index(after i: Index) -> Index {
        return queue.sync {
            return underlyingDictionary.index(after: i)
        }
    }

    subscript(key: KeyType) -> ValueType? {
        get {
            var value: ValueType?
            queue.sync { value = self.underlyingDictionary[key] }
            return value
        }

        set {
            queue.sync {
                self.underlyingDictionary[key] = newValue
            }
        }
    }

    func removeValue(forKey key: KeyType) -> ValueType? {
        var oldValue: ValueType? = nil
        queue.sync {
            oldValue = self.underlyingDictionary.removeValue(forKey: key)
        }
        return oldValue
    }

    func removeAll() {
        queue.sync {
            self.underlyingDictionary.removeAll()
        }
    }

    func forEach(_ body: ((key: KeyType, value: ValueType)) -> Void) {
        queue.sync {
            underlyingDictionary.forEach(body)
        }
    }

    func first(where predicate: ((key: KeyType, value: ValueType)) -> Bool) -> (key: KeyType, value: ValueType)? {
        return queue.sync {
            return underlyingDictionary.first(where: predicate)
        }
    }

    func reduce<Result>(
        into initialResult: Result,
        _ updateAccumulatingResult: (inout Result, (key: KeyType, value: ValueType)) throws -> ()
    ) rethrows -> Result {
        return try queue.sync {
            return try underlyingDictionary.reduce(into: initialResult, updateAccumulatingResult)
        }
    }
}
