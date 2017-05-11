import Foundation

public class PCSynchronizedArray<T> {
    private var array: [T] = []
    private let accessQueue = DispatchQueue(label: "synchronized.array.access", attributes: .concurrent)

    public func append(_ newElement: T) {
        self.accessQueue.async(flags: .barrier) {
            self.array.append(newElement)
        }
    }

    public func removeAtIndex(index: Int) {
        self.accessQueue.async(flags: .barrier) {
            self.array.remove(at: index)
        }
    }

    public var count: Int {
        var count = 0

        self.accessQueue.sync {
            count = self.array.count
        }

        return count
    }

    public func first() -> T? {
        var element: T?

        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array[0]
            }
        }

        return element
    }

    public func first(where predicate: (T) -> Bool) -> T? {
        var element: T?

        self.accessQueue.sync {
            element = self.array.first(where: predicate)
        }

        return element
    }

    public func remove(where predicate: @escaping (T) -> Bool) -> T? {
        var element: T?

        self.accessQueue.async(flags: .barrier) {
            guard let index = self.array.index(where: predicate) else { return }
            element = self.array.remove(at: index)
        }

        return element
    }

    public func filter(_ isIncluded: @escaping (T) -> Bool) -> [T] {
        var result = [T]()
        self.accessQueue.sync { result = self.array.filter(isIncluded) }
        return result
    }

    public func flatMap<ElementOfResult>(_ transform: @escaping (T) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        self.accessQueue.sync { result = self.array.flatMap(transform) }
        return result
    }

    public subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
        get {
            var element: T!
            self.accessQueue.sync {
                element = self.array[index]
            }

            return element
        }
    }
}
