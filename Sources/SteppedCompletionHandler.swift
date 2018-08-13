import Foundation

// FIXME: Things creating `steppedCompletionHandler`s don't know that the DispatchQueue
// they provide is going to be used for a DispatchGroup, and so aren't necessarily
// aware of the contract that is expected. As such is quite easy to get into a
// situation where there is an unbalanced number of `leave()` calls for the number of
// `enter()` calls before the object is no longer retained. This can lead to an
// `EXC_BAD_INSTRUCTION` error. The fix is either to ensure that all of the `leave()`
// calls are guaranteed to occur before the `steppedCompletionHandler` goes out of
// scope, or perhaps give every `steppedCompletionHandler` its own `DispatchQueue`

// Takes an `inner` completion handler of type `PCErrorCompletionHandler`,
// returns another completion handler of the same type that calls the inner
// completion handler after being called itself `steps` times. Returns the last
// error, if any.
func steppedCompletionHandler(
    steps: Int,
    inner: @escaping PCErrorCompletionHandler,
    dispatchQueue: DispatchQueue
) -> PCErrorCompletionHandler {
    guard steps > 0 else {
        inner(nil)
        return { _ in }
    }

    var error: Error?

    let group = DispatchGroup()

    for _ in 0..<steps {
        group.enter()
    }

    group.notify(queue: dispatchQueue) { inner(error) }

    return { err in
        error = err
        group.leave()
    }
}

func steppedCompletionHandler(
    steps: Int,
    inner: @escaping () -> Void,
    dispatchQueue: DispatchQueue
) -> () -> Void {
    guard steps > 0 else {
        inner()
        return {}
    }

    let group = DispatchGroup()

    for _ in 0..<steps {
        group.enter()
    }

    group.notify(queue: dispatchQueue) { inner() }

    return { group.leave() }
}
