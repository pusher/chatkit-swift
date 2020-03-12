import class PusherPlatform.PPResumableSubscription

protocol ResumableSubscription: AnyObject {
    func terminate()
}

extension PusherPlatform.PPResumableSubscription: ResumableSubscription {
    
    func terminate() {
        self.onOpen = nil
        self.onOpening = nil
        self.onResuming = nil
        self.onEvent = nil
        self.onError = nil
        self.onEnd = nil
        self.end()
    }
}
