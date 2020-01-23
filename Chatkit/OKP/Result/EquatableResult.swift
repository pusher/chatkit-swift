
enum EquatableResult<Success: Equatable> {
    case success(Success)
    case failure(Error)
}

extension EquatableResult: Equatable {
    
    public static func ==(lhs: EquatableResult<Success>, rhs: EquatableResult<Success>) -> Bool {
        switch (lhs) {
        case .success(let lhsSuccess):
            if case .success(let rhsSuccess) = rhs, lhsSuccess == rhsSuccess { return true }
        case .failure(let lhsError):
            // We cast associated Error to a NSError so we get Equatable behaviour
            // (Apple guarantee that Error can always be bridged to an NSError)
            if case .failure(let rhsError) = rhs, lhsError as NSError == rhsError as NSError { return true }
        }
        return false
    }
}

