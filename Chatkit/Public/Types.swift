import Foundation

/// A dictionary of objects which can be used to store arbitrary metadata on a variety of Chatkit entities.
///
/// All objects stored in the dictionary must conform to a valid JSON data type. In addition, all keys used
/// by the dictionary must be `String`s.
public typealias CustomData = [String : Any]

/// A closure to be executed by the SDK when an asynchronous operation completes.
///
/// - Parameters:
///     - error: An optional error object which describes the issue that occurred during the execution
///     of the asynchronous operation, or `nil` if the asynchronous operation completed successfully.
public typealias CompletionHandler = (Error?) -> Void
