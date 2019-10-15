import Foundation

/// A dictionary of object provided by the user.
///
/// All objects stored in the dictionary must conform to a valid JSON data type. In addition to that keys used
/// by the dictionary must be represented by `String` objects.
public typealias Metadata = [String : Any]

/// A closure that is being executed by the SDK when an asynchronous operation has been completed.
///
/// - Parameters:
///     - error: An optional error object which describes the issue that occurred during the execution
///     of the asynchronous operation, or `nil` if the asynchronous operation completed successfully.
public typealias CompletionHandler = (Error?) -> Void
