import PusherPlatform

// TODO: Should this have the delegate or the PCRoom itself?

public class PCRoomSubscription {
    public var delegate: PCRoomDelegate?
    let resumableSubscription: ResumableSubscription
    public let completionHandler: (Error?) -> Void

    public init(delegate: PCRoomDelegate? = nil, resumableSubscription: ResumableSubscription, completionHandler: @escaping (Error?) -> Void) {
        self.delegate = delegate
        self.resumableSubscription = resumableSubscription
        self.completionHandler = completionHandler
    }

    public func handleEvent(eventId: String, headers: [String: String], data: Any) {

    }

    //    public func handleEvent(room: PCRoom, message: PCMessage) {
    //        self.delegate?.messageReceived(room: room, message: message)
    //    }
}
