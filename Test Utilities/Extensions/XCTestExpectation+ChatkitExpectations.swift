import XCTest
@testable import PusherChatkit

extension XCTestExpectation {
    
    // Note all properties here are computed `var`s (and not `let`s) to avoid a
    // "API violation - expectations can only be waited on once" error in the event
    // the same expectation is used twice in the same test.
    // (we often want to test two calls to `Chatkit.connect` for example)
    
    public struct Chatkit {
        
        public static var connect: Expectation<Error?> {
            .init(functionName: "connect", systemTestTimeout: 15)
        }
        
    }
    
    public struct SubscriptionManager {
        
        public static var subscribe: Expectation<VoidResult> {
            .init(functionName: "subscribe", systemTestTimeout: 15)
        }
        
    }
    
    public struct Subscription {
        
        public static var subscribe: Expectation<VoidResult> {
            .init(functionName: "subscribe", systemTestTimeout: 15)
        }
        
    }
    
    public struct JoinedRoomsProviderDelegate {
        
        public static var didJoinRoom: Expectation<Room> {
            .init(functionName: "didJoinRoom", systemTestTimeout: 15)
        }
        
        public static var didLeaveRoom: Expectation<Room> {
            .init(functionName: "didLeaveRoom", systemTestTimeout: 15)
        }
        
    }
    
}
