import Foundation

public final class PCSynchronizedArray<T> {
    internal var underlyingArray: [T] = []
    private let accessQueue = DispatchQueue(label: "synchronized.array.access", attributes: .concurrent)

    public init() {}

    public func append(_ newElement: T, completionHandler: (() -> Void)? = nil) {
        // QoS is userInitiated here, mainly so that when the rooms are received as part
        // of the initial_state for a user subscription they are added to the room store
        // before the connectCompletionHandlers are called, where it would be likely that
        // the rooms property of the currentUser would be accessed - maybe there's a better
        // way to ensure ordering by dispatching some part of it on the main queue?
        self.accessQueue.async(qos: .userInitiated, flags: .barrier) {
            self.underlyingArray.append(newElement)

            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }

    func appendAndComplete(_ newElement: T, completionHandler: @escaping (T) -> Void) {

        // TODO: Does this need a userInitiated QoS as well?

        self.accessQueue.async(qos: .userInitiated, flags: .barrier) {
            self.underlyingArray.append(newElement)

            DispatchQueue.main.async {
                completionHandler(newElement)
            }
        }
    }

    public func remove(where predicate: @escaping (T) -> Bool, completionHandler: ((T?) -> Void)? = nil) {
        self.accessQueue.async(flags: .barrier) {
            guard let index = self.underlyingArray.index(where: predicate) else {
                completionHandler?(nil)
                return
            }

            let element = self.underlyingArray.remove(at: index)

            DispatchQueue.main.async {
                completionHandler?(element)
            }
        }
    }

    public func remove(at index: Int, completionHandler: ((T) -> Void)? = nil) {
        self.accessQueue.async(flags: .barrier) {
            let element = self.underlyingArray.remove(at: index)

            DispatchQueue.main.async {
                completionHandler?(element)
            }
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
        self.accessQueue.async(flags: .barrier) {
            guard let index = self.underlyingArray.index(where: predicate) else { return }
            let element = self.underlyingArray.remove(at: index)

            DispatchQueue.main.async {
                completion?(element)
            }
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

    public func flatMap<ElementOfResult>(_ transform: @escaping (T) -> ElementOfResult?) -> [ElementOfResult] {
        var result = [ElementOfResult]()
        self.accessQueue.sync { result = self.underlyingArray.flatMap(transform) }
        return result
    }

    public func forEach(_ body: (T) -> Void) {
        self.accessQueue.sync { self.underlyingArray.forEach(body) }
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
