import XCTest
import class PusherPlatform.PPGeneralRequest
import class PusherPlatform.PPRequestOptions
import struct PusherPlatform.PPSDKInfo
@testable import PusherChatkit

public class DummyInstance: DummyBase, Instance {
    
    public func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest {
        DummyFail(sender: self, function: #function)
        return PPGeneralRequest()
    }
    
    public func subscribeWithResume(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String: String], Any) -> Void)?, onEnd: ((Int?, [String: String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> ResumableSubscription {
        DummyFail(sender: self, function: #function)
        return DummyResumableSubscription(file: file, line: line)
    }
}

public class StubInstance: DoubleBase, Instance {
    
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

    public init(subscribe_completionResult: VoidResult? = nil,
        file: StaticString = #file, line: UInt = #line) {
        self.subscribe_completionResult = subscribe_completionResult
        super.init(file: file, line: line)
    }
    
    public func stub(_ urlString: String, _ jsonData: Data) {}
    
    // Preparing for registration to a subscription
    private var subscribe_completionResult: VoidResult?
    public func stubSubscribe(result: VoidResult) {
        subscribe_completionResult = result
    }
    
    private var subscriptionEnd_expected = false
    public func stubSubscriptionEnd() {
        if let internalStubResumableSubscription = internalStubResumableSubscription {
            internalStubResumableSubscription.increment_end_expectedCallCount()
        } else {
            subscriptionEnd_expected = true
        }
    }
    
    // Live firing of subscription events
    public func fireSubscriptionEvent(jsonData: Data) {
        guard let onEvent = self.onEvent else {
            XCTFail("`\(#function)` was called but `\(String(describing: self)).onEvent` was NOT defined", file: file, line: line)
            return
        }
        // TODO: This should be removed once we've updated the PusherPlatform to return data rather than a jsonDict.
        guard let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) else {
            XCTFail("`\(#function)` was called but the jsonData passed was NOT JSON parsable", file: file, line: line)
            return
        }
        
        let eventId = ""
        let headers: [String: String] = [:]
        onEvent(eventId, headers, jsonDict)
    }
    
    // MARK: Instance implementation
    
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
    
    private var onOpening: Instance.OnOpening?
    private var onOpen: Instance.OnOpen?
    private var onResuming: Instance.OnResuming?
    private var onEvent: Instance.OnEvent?
    private var onEnd: Instance.OnEnd?
    private var onError: Instance.OnError?
    
    // We have to hold a reference to these otherwise they get deallocated and cause issues
//    private var instance: Instance?
//    private var resumableSubscription: PusherPlatform.PPResumableSubscription?
    
    public private(set) var subscribeWithResume_actualCallCount: UInt = 0
    
    public func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: Instance.OnOpening?,
                             onOpen: Instance.OnOpen?,
                             onResuming: Instance.OnResuming?,
                             onEvent: Instance.OnEvent?,
                             onEnd: Instance.OnEnd?,
                             onError: Instance.OnError?) -> ResumableSubscription {
        
        subscribeWithResume_actualCallCount += 1
        
        guard let subscribe_completionResult = subscribe_completionResult else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))`", file: file, line: line)
            return DummyResumableSubscription(file: file, line: line)
        }
        
        self.onOpening = onOpening
        self.onOpen = onOpen
        self.onResuming = onResuming
        self.onEvent = onEvent
        self.onEnd = onEnd
        self.onError = onError
        
        switch subscribe_completionResult {
            // TODO: no idea if this is correct
        case .success:
            onOpen?()
        case let .failure(error):
            // TODO: no idea if this is correct
            let statusCode = 404
            let headers: [String: String]? = nil
            let info: Any? = error
            onError?(error)
            onEnd?(statusCode, headers, info)
        }
        
        let end_expectedCallCount: UInt = subscriptionEnd_expected ? 1 : 0
        let stubResumableSubscription = StubResumableSubscription(end_expectedCallCount: end_expectedCallCount, file: file, line: line)
        internalStubResumableSubscription = stubResumableSubscription
        return stubResumableSubscription
    }
    
}
