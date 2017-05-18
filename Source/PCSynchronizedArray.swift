import Foundation

public class PCSynchronizedArray<T> {
    internal var underlyingArray: [T] = []
    private let accessQueue = DispatchQueue(label: "synchronized.array.access", attributes: .concurrent)

    public func append(_ newElement: T) {
        self.accessQueue.async(flags: .barrier) {
            self.underlyingArray.append(newElement)
        }
    }

    public func removeAtIndex(index: Int) {
        self.accessQueue.async(flags: .barrier) {
            self.underlyingArray.remove(at: index)
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

    public func remove(where predicate: @escaping (T) -> Bool) -> T? {
        var element: T?

        self.accessQueue.async(flags: .barrier) {
            guard let index = self.underlyingArray.index(where: predicate) else { return }
            element = self.underlyingArray.remove(at: index)
        }

        return element
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

    public func flatMap<ElementOfResult>(_ transform: @escaping (T) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        self.accessQueue.sync { result = self.underlyingArray.flatMap(transform) }
        return result
    }

    public subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags: .barrier) {
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
