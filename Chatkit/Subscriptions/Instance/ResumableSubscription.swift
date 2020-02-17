import class PusherPlatform.PPResumableSubscription

protocol ResumableSubscription: AnyObject {
    var onOpen: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func end()
}

extension PusherPlatform.PPResumableSubscription: ResumableSubscription {}
