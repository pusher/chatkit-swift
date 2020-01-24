
enum EquatableResult<Success: Equatable> {
    case success(Success)
    case failure(Error)
}

extension EquatableResult: Equatable {
    
    public static func == (lhs: EquatableResult<Success>, rhs: EquatableResult<Success>) -> Bool {
        switch lhs {
        case let .success(lhsSuccess):
            if case let .success(rhsSuccess) = rhs, lhsSuccess == rhsSuccess { return true }
        case let .failure(lhsError):
            // We cast associated Error to a NSError so we get Equatable behaviour
            // (Apple guarantee that Error can always be bridged to an NSError)
            if case let .failure(rhsError) = rhs, lhsError as NSError == rhsError as NSError { return true }
        }
        return false
    }
}
