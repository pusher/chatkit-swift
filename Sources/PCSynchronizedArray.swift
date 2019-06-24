import Foundation

public final class PCSynchronizedArray<T> {
    private var underlyingArray: [T] = []
    private let accessQueue = DispatchQueue(label: "synchronized.array.access.\(UUID().uuidString)")

    public init() {}

    func clone() -> [T] {
        return self.accessQueue.sync {
            return underlyingArray
        }
    }

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
        return self.accessQueue.sync {
            return self.underlyingArray.count
        }
    }

    public var isEmpty: Bool {
        return self.accessQueue.sync {
            return self.underlyingArray.isEmpty
        }
    }

    public func first(where predicate: (T) -> Bool) -> T? {
        return self.accessQueue.sync {
            return self.underlyingArray.first(where: predicate)
        }
    }

    public var first: T? {
        return self.accessQueue.sync {
            return self.underlyingArray.first
        }
    }

    public var last: T? {
        return self.accessQueue.sync {
            return self.underlyingArray.last
        }
    }

    public func filter(_ isIncluded: @escaping (T) -> Bool) -> [T] {
        return self.accessQueue.sync {
            return self.underlyingArray.filter(isIncluded)
        }
    }

    public func sorted(by areInIncreasingOrder: (T, T) -> Bool) -> [T] {
        return self.accessQueue.sync {
            return self.underlyingArray.sorted(by: areInIncreasingOrder)
        }
    }

    public func compactMap<ElementOfResult>(_ transform: @escaping (T) -> ElementOfResult?) -> [ElementOfResult] {
        return self.accessQueue.sync {
            return self.underlyingArray.compactMap(transform)
        }
    }

    public func forEach(_ body: (T) -> Void) {
        self.accessQueue.sync {
            self.underlyingArray.forEach(body)
        }
    }

    public subscript(index: Int) -> T {
        set {
            self.accessQueue.sync {
                self.underlyingArray[index] = newValue
            }
        }
        get {
            return self.accessQueue.sync {
                return self.underlyingArray[index]
            }
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
