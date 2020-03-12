import XCTest
import class PusherPlatform.PPGeneralRequest
import class PusherPlatform.PPRequestOptions
import struct PusherPlatform.PPSDKInfo
@testable import PusherChatkit

public class DummyInstanceWrapper: DummyBase, InstanceWrapper {
    
    public func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest {
        DummyFail(sender: self, function: #function)
        return PPGeneralRequest()
    }
    
    public func subscribeWithResume(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String: String], Any) -> Void)?, onEnd: ((Int?, [String: String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> ResumableSubscription {
        DummyFail(sender: self, function: #function)
        return DummyResumableSubscription(file: file, line: line)
    }
}

public enum SubscribeOutcome {
    case wait
    case openAndWait
    case open(initialStateJsonData: Data)
    case fail(error: Error)
}

public class StubInstanceWrapper: DoubleBase, InstanceWrapper {
    
    struct Expectation {
        let url: String
        let jsonData: Data
        
        func matches(_ options: PPRequestOptions) -> Bool {
            switch options.destination {
            case let .relative(relativePath):
                return url.hasSuffix(relativePath)
            case let .absolute(absoluteURL):
                return url == absoluteURL
            }
        }
    }
    
    private var expectations: [Expectation] = []
    
    // Property is `weak` to emulate its real world equivalent
    private weak var internalStubResumableSubscription: StubResumableSubscription?

    public init(subscribeWithResume_outcomes: [SubscribeOutcome] = [],
                resumableSubscription_terminate_expected: Bool = false,
                file: StaticString = #file, line: UInt = #line) {
        self.subscribeWithResume_outcomes = subscribeWithResume_outcomes
        self.resumableSubscription_terminate_expected = resumableSubscription_terminate_expected
        super.init(file: file, line: line)
    }
    
    public func stub(_ urlString: String, _ jsonData: Data) {}
    
    // Preparing for registration to a subscription
    private var subscribeWithResume_outcomes: [SubscribeOutcome] = []
    public func stubSubscribe(outcome: SubscribeOutcome) {
        subscribeWithResume_outcomes.append(outcome)
    }
    
    private var resumableSubscription_terminate_expected = false
    public func stubResumableSubscriptionEnd() {
        if let internalStubResumableSubscription = internalStubResumableSubscription {
            internalStubResumableSubscription.increment_terminate_expectedCallCount()
        } else {
            resumableSubscription_terminate_expected = true
        }
    }
    
    // MARK: Live firing of subscription events
    
    public func fireOnOpening() {
        onOpening?()
    }
    
    public func fireOnOpen() {
        onOpen?()
    }
    
    public func fireOnResuming() {
        onResuming?()
    }
    
    public func fireOnEvent(jsonData: Data) {
        let eventId = ""
        let headers: [String: String] = [:]
        onEvent?(eventId, headers, jsonData)
    }
    
    public func fireOnEnd() {
        // TODO: Subscription unhappy paths
        // It was decided to defer work on handling Subscription *un*happy paths in favour
        // of shipping the happy paths on the SDK
        // Need to work out the values a PusherPlatform.Instance sends in real life
        let statusCode = -1
        let headers: [String: String]? = nil
        let info: Any? = nil
        onEnd?(statusCode, headers, info)
    }
    
    public func fireOnError(error: Error) {
        onError?(error)
    }
    
    // MARK: InstanceWrapper implementation
    
    public private(set) var request_actualCallCount: UInt = 0
    
    public func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest {
        
        request_actualCallCount += 1
        
        let generalRequest = PPGeneralRequest()
        
        guard let index = expectations.firstIndex(where: { $0.matches(requestOptions) }) else {
            XCTFail()
            return generalRequest
        }
        
        let expectation = expectations[index]
        expectations.remove(at: index)
        
        onSuccess?(expectation.jsonData)
        
        return generalRequest
    }
    
    private var onOpening: InstanceWrapper.OnOpening?
    private var onOpen: InstanceWrapper.OnOpen?
    private var onResuming: InstanceWrapper.OnResuming?
    private var onEvent: InstanceWrapper.OnEvent?
    private var onEnd: InstanceWrapper.OnEnd?
    private var onError: InstanceWrapper.OnError?
    
    // We have to hold a reference to these otherwise they get deallocated and cause issues
//    private var instanceWrapper: InstanceWrapper?
//    private var resumableSubscription: PusherPlatform.PPResumableSubscription?
    
    public private(set) var subscribeWithResume_actualCallCount: UInt = 0
    
    public func subscribeWithResume(using _: PPRequestOptions,
                                    onOpening: InstanceWrapper.OnOpening?,
                                    onOpen: InstanceWrapper.OnOpen?,
                                    onResuming: InstanceWrapper.OnResuming?,
                                    onEvent: InstanceWrapper.OnEvent?,
                                    onEnd: InstanceWrapper.OnEnd?,
                                    onError: InstanceWrapper.OnError?) -> ResumableSubscription {
        
        subscribeWithResume_actualCallCount += 1
        
        guard let subscribeWithResume_outcome = subscribeWithResume_outcomes.removeOptionalFirst() else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))`", file: file, line: line)
            return DummyResumableSubscription(file: file, line: line)
        }
        
        self.onOpening = onOpening
        self.onOpen = onOpen
        self.onResuming = onResuming
        self.onEvent = onEvent
        self.onEnd = onEnd
        self.onError = onError
        
        DispatchQueue.main.async {

            // TODO: Subscription unhappy paths
            // It was decided to defer work on handling Subscription *un*happy paths in favour
            // of shipping the happy paths on the SDK
            // We need to check how PusherPlatform.Instance behaves in real life
            //      Should these be delayed async calls so they don't happen till the next run loop?
            //      Are we invoked the correct events in the right order?
            
            switch subscribeWithResume_outcome {
            case .wait:
                // Do nothing, the test should manually invoke its own events
                ()
            case .openAndWait:
                // Simulate the opening of the connection but DO NOT fire the first event
                self.fireOnOpening()
                self.fireOnOpen()
            case let .open(initialStateJsonData):
                self.fireOnOpening()
                self.fireOnOpen()
                self.fireOnEvent(jsonData: initialStateJsonData)
            case let .fail(error):
                self.fireOnOpening()
                self.fireOnError(error: error)
                self.fireOnEnd()
            }
        }
        
        let terminate_expectedCallCount: UInt
        if case .fail = subscribeWithResume_outcome {
            terminate_expectedCallCount = 1
        } else {
            terminate_expectedCallCount = resumableSubscription_terminate_expected ? 1 : 0
        }
        
        let stubResumableSubscription = StubResumableSubscription(terminate_expectedCallCount: terminate_expectedCallCount, file: file, line: line)
        internalStubResumableSubscription = stubResumableSubscription
        return stubResumableSubscription
    }
    
}
