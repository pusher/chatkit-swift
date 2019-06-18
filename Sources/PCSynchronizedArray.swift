import Foundation

public final class PCSynchronizedArray<T> {
    internal var underlyingArray: [T] = []
    private let accessQueue = DispatchQueue(label: "synchronized.array.access.\(UUID().uuidString)")

    public init() {}

    func append(_ newElement: T) -> T {
        self.accessQueue.sync {
            self.underlyingArray.append(newElement)
        }

        return newElement
    }

    public func remove(where predicate: @escaping (T) -> Bool) -> T? {
        return self.accessQueue.sync {
            guard let index = self.underlyingArray.index(where: predicate) else {
                return nil
            }

            return self.underlyingArray.remove(at: index)
        }
    }

    public var count: Int {
        var count = 0

        self.accessQueue.sync {
            count = self.underlyingArray.count
        }

        return count
    }

    public var isEmpty: Bool {
        var result = false
        self.accessQueue.sync { result = self.underlyingArray.isEmpty }
        return result
    }

    public func first(where predicate: (T) -> Bool) -> T? {
        var element: T?

        self.accessQueue.sync {
            element = self.underlyingArray.first(where: predicate)
        }

        return element
    }

    public var first: T? {
        var result: T?
        self.accessQueue.sync { result = self.underlyingArray.first }
        return result
    }

    public var last: T? {
        var result: T?
        self.accessQueue.sync { result = self.underlyingArray.last }
        return result
    }

    public func remove(where predicate: @escaping (T) -> Bool, completion: ((T) -> Void)? = nil) {
        self.accessQueue.async {
            guard let index = self.underlyingArray.index(where: predicate) else { return }
            let element = self.underlyingArray.remove(at: index)
            completion?(element)
        }
    }

    public func filter(_ isIncluded: @escaping (T) -> Bool) -> [T] {
        var result = [T]()
        self.accessQueue.sync { result = self.underlyingArray.filter(isIncluded) }
        return result
    }

    public func sorted(by areInIncreasingOrder: (T, T) -> Bool) -> [T] {
        var result = [T]()
        self.accessQueue.sync { result = self.underlyingArray.sorted(by: areInIncreasingOrder) }
        return result
    }

    public func compactMap<ElementOfResult>(_ transform: @escaping (T) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        self.accessQueue.sync { result = self.underlyingArray.compactMap(transform) }
        return result
    }

    public func forEach(_ body: (T) -> Void) {
        self.accessQueue.sync { self.underlyingArray.forEach(body) }
    }

    public subscript(index: Int) -> T {
        set {
            self.accessQueue.sync {
                self.underlyingArray[index] = newValue
            }
        }
        get {
            var element: T!
            self.accessQueue.sync {
                element = self.underlyingArray[index]
            }

            return element
        }
    }
}

extension PCSynchronizedArray where T: PCUpdatable {
    func appendOrUpdate(_ value: T, predicate: @escaping (T) -> Bool) -> T {
        return self.accessQueue.sync {
            if let existingValue = self.underlyingArray.first(where: predicate) {
                existingValue.updateWithPropertiesOf(value)
                return existingValue
            } else {
                self.underlyingArray.append(value)
                return value
            }
        }
    }
}
