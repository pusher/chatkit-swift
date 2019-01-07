import Foundation

enum InitialStateResult<T: Hashable> {
    case error(Error)
    case success(existing: [T], new: [T])
}
