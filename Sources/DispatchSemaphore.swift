import Foundation

extension DispatchSemaphore {
    func synchronized<T>(_ operation: () -> T) -> T {
        self.wait()
        let v = operation()
        self.signal()
        return v
    }
}
