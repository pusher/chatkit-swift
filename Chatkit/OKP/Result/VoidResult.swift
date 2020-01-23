
enum VoidResult {
    case success
    case failure(Error)
}

extension VoidResult: Equatable {
    
    public static func ==(lhs: VoidResult, rhs: VoidResult) -> Bool {
        switch (lhs) {
        case .success:
            if case .success = rhs { return true }
        case .failure(let lhsError):
            // We cast associated Error to a NSError so we get Equatable behaviour
            // (Apple guarantee that Error can always be bridged to an NSError)
            if case .failure(let rhsError) = rhs, lhsError as NSError == rhsError as NSError { return true }
        }
        return false
    }
}
